import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runmore/db/app_database.dart';

@pragma('vm:entry-point') // 백그라운드에서 불리려면 꼭 필요
void runLocationStartCallback() {
  FlutterForegroundTask.setTaskHandler(RunLocationTaskHandler());
}

class RunLocationTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _posSub;
  Position? _latestPosition;
  Position? _lastPosition;
  DateTime? _lastTs;
  DateTime? _lastPosTs;

  double _totalDistance = 0.0; // m
  int _elapsedSeconds = 0;

  DateTime? _startTs;

  // 자동 일시정지 관련
  bool _autoPaused = false;
  bool _userPaused = false;
  int _lowSpeedSeconds = 0;
  int _resumeCandTicks = 0;

  // ✅ 1km 구간(스플릿) 보간 계산용
  double _segAccDist = 0.0; // 현재 구간 누적 거리(m)
  int _segAccTime = 0; // 현재 구간 누적 시간(s)
  int _segIndex = 0; // 완료한 1km 개수 (1,2,3...)
  int _segCumulativeSeconds = 0; // "km 단위로 끊은" 누적 시간

  bool? _prevIsPaused;
  bool? _prevAutoPaused;

  AppDatabase? _db;
  DateTime? _lastStateSavedAt;

  bool get _isPaused => _autoPaused || _userPaused;

  static const double _autoPauseSpeedThreshold = 0.7; // m/s (~2.5km/h)
  static const int _autoPauseSeconds = 5; // 5초 이상 천천히/멈춤 → pause

  @override
  void onReceiveData(Object data) {
    // UI에서 Map 형태로 보냈으니 Map으로 처리
    if (data is Map) {
      final cmd = data['cmd'];

      if (cmd == 'pause') {
        // 수동 일시정지
        _userPaused = true;
      } else if (cmd == 'resume') {
        // 수동 재시작
        _userPaused = false;
        // 재시작 직후 바로 다시 auto-pause 걸리지 않게 초기화
        _lowSpeedSeconds = 0;
      } else if (cmd == 'finalize') {
        _sendFinalizeIfNeeded();

        FlutterForegroundTask.sendDataToMain({'event': 'finalize_done'});
      } else if (cmd == 'get_state') {
        FlutterForegroundTask.sendDataToMain({
          'event': 'state',
          'distanceMeters': _totalDistance,
          'elapsedSeconds': _elapsedSeconds,
          'isPaused': _isPaused,
          'autoPaused': _autoPaused,
          'userPaused': _userPaused,
        });
      }
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _startTs = DateTime.now();
    _elapsedSeconds = 0;
    _autoPaused = false;
    _userPaused = false;
    _lowSpeedSeconds = 0;
    _segAccDist = 0.0;
    _segAccTime = 0;
    _segIndex = 0;
    _segCumulativeSeconds = 0;
    _lastTs = null;
    _lastPosition = null;
    _latestPosition = null;
    _prevIsPaused = null;
    _prevAutoPaused = null;
    _lastStateSavedAt = null;
    _lastPosTs = null;

    final settings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      intervalDuration: const Duration(seconds: 1),
    );

    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (p) {
        _latestPosition = p;
      },
      onError: (e) {
        FlutterForegroundTask.sendDataToMain({
          'event': 'dbg',
          'reason': 'pos_stream_error',
          'error': '$e',
        });
      },
      cancelOnError: false,
    );
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    final hasPerm = await _ensurePermission();
    if (!hasPerm) return;

    final db = await _getDb();

    final now = DateTime.now();

    int rawDt = 1;
    if (_lastTs != null) {
      rawDt = now.difference(_lastTs!).inSeconds;
      if (rawDt <= 0) rawDt = 1;
    }
    _lastTs = now;

    // ✅ autoPause 판단용 dt는 clamp 유지
    final int dt = rawDt.clamp(1, 3);

    // =========================
    // ✅ 시간은 "여기서 한 번만" 처리 (핵심)
    // - 새 GPS가 없어도 시간은 흐르게 해야 함
    // =========================
    if (!_isPaused) {
      _elapsedSeconds += rawDt;
      _segAccTime += rawDt;
    }

    // 공통 avgSpeed (거리 업데이트 전/후 모두 이 계산식 사용)
    double avgSpeed() => _elapsedSeconds > 0 ? _totalDistance / _elapsedSeconds : 0.0;

    // ✅ 공통 flush: 알림 업데이트 + pause 이벤트 + state upsert + UI send
    Future<void> flush({Position? pos}) async {
      final a = avgSpeed();

      // 알림 업데이트
      final elapsedText = _formatElapsed(_elapsedSeconds);
      final prefix = _isPaused ? '일시정지 중 ' : '';
      await FlutterForegroundTask.updateService(
        notificationTitle: '런모아 달리는 중',
        notificationText: '${(_totalDistance / 1000).toStringAsFixed(2)} km | $prefix$elapsedText',
      );

      // pause 이벤트
      final nowIsPaused = _isPaused;
      if (_prevIsPaused == null || _prevIsPaused != nowIsPaused) {
        FlutterForegroundTask.sendDataToMain({
          'event': 'pause_changed',
          'isPaused': nowIsPaused,
          'autoPaused': _autoPaused,
          'userPaused': _userPaused,
        });
        _prevIsPaused = nowIsPaused;
      }

      if (_prevAutoPaused == null || _prevAutoPaused != _autoPaused) {
        FlutterForegroundTask.sendDataToMain({
          'event': 'auto_pause_changed',
          'autoPaused': _autoPaused,
        });
        _prevAutoPaused = _autoPaused;
      }

      // ✅ state는 5초마다 1행 upsert (새 위치 없어도!)
      final stateNow = DateTime.now();
      final shouldSaveState =
          _lastStateSavedAt == null || stateNow.difference(_lastStateSavedAt!).inSeconds >= 5;

      if (shouldSaveState) {
        _lastStateSavedAt = stateNow;

        await db.into(db.runningState).insertOnConflictUpdate(
          RunningStateCompanion.insert(
            id: const drift.Value(1),
            startedAt: _startTs ?? stateNow,
            lastTs: drift.Value(stateNow),
            distanceMeters: _totalDistance,
            elapsedSeconds: _elapsedSeconds,
            avgSpeedMps: a,
            isPaused: _isPaused,
          ),
        );
      }

      // UI 전송 (pos 없으면 lat/lng 생략)
      FlutterForegroundTask.sendDataToMain({
        'ts': stateNow.toIso8601String(),
        if (pos != null) 'lat': pos.latitude,
        if (pos != null) 'lng': pos.longitude,
        if (pos != null) 'altitude': pos.altitude,
        if (pos != null) 'accuracy': pos.accuracy,
        'distanceMeters': _totalDistance,
        'elapsedSeconds': _elapsedSeconds,
        'avgSpeedMps': a,
        'isPaused': _isPaused,
      });
    }

    // =========================
    // ✅ 위치 없으면: 표시/저장만 하고 종료
    // (선택) autoPause 누적을 하고 싶으면 여기서 lowSpeedSeconds += dt
    // =========================
    final position = _latestPosition;
    if (position == null) {
      // (옵션) GPS가 안오면 멈춘 걸로 보고 autoPause 누적
      if (!_autoPaused) {
        _lowSpeedSeconds += dt;
        if (_lowSpeedSeconds >= _autoPauseSeconds) {
          _autoPaused = true;
          _resumeCandTicks = 0;
        }
      }
      await flush(pos: null);
      return;
    }

    // =========================
    // ✅ stale pos면: 거리/계산 스킵, 대신 표시/저장 계속
    // =========================
    final posTs = position.timestamp ?? now;
    if (_lastPosTs != null && !posTs.isAfter(_lastPosTs!)) {
      // (옵션) stale이면 멈춘 걸로 보고 autoPause 누적
      if (!_autoPaused) {
        _lowSpeedSeconds += dt;
        if (_lowSpeedSeconds >= _autoPauseSeconds) {
          _autoPaused = true;
          _resumeCandTicks = 0;
        }
      }
      await flush(pos: position);
      return;
    }
    _lastPosTs = posTs;


    // =========================
    // ✅ accuracy 필터 (핵심)
    // =========================
    const double maxAccuracyM = 25.0; // 러닝 기록에는 보통 20~30m 이하만 쓰는게 안전?
    final double acc = position.accuracy; // meters

    // 정확도가 너무 나쁘면:
    // - lastPosition 갱신 ❌ (기준점 오염 방지)
    // - autoPause 계산도 이번 tick은 스킵(플래핑 방지)
    if (!acc.isFinite || acc > maxAccuracyM) {
      //
      // await FlutterForegroundTask.updateService(
      //   notificationTitle: '런모아 달리는 중',
      //   notificationText:
      //   '${(_totalDistance / 1000).toStringAsFixed(2)} km | 정확도 불안정(${acc.toStringAsFixed(0)}m)',
      // );
      //
      // FlutterForegroundTask.sendDataToMain({
      //   'event': 'dbg',
      //   'reason': 'bad_accuracy',
      //   'accuracy': acc,
      // });

      // 위치는 UI에 찍어도 되지만(지도 점프 유발), 난 스킵 추천.
      // 여기서는 스킵(=지도 흔들림 최소화)

      // 정확도 나쁘면 거리/autoResume 판단 스킵, 대신 표시/저장 계속
      // (옵션) 이 경우도 멈춘 걸로 보고 autoPause 누적할지 선택
      // if (!_autoPaused) {
      //   _lowSpeedSeconds += dt;
      //   if (_lowSpeedSeconds >= _autoPauseSeconds) {
      //     _autoPaused = true;
      //     _resumeCandTicks = 0;
      //   }
      // }
      await flush(pos: position);
      return;
    }

    final prev = _lastPosition;

    // ----- 노이즈/속도 파라미터 -----
    const double minDistance = 5.0; // 5m 미만은 흔들림 취급
    const double minSpeedMps = 1.0; // 3.6km/h (거리 누적 기준)
    const double maxHumanSpeedMps = 8.0;
    final double maxDistance = max(30.0, maxHumanSpeedMps * rawDt + 10.0);
    // autoPause는 별도(_autoPauseSpeedThreshold=0.7)로 판단
    // --------------------------------

    if (prev != null) {
      final d = _haversine(prev.latitude, prev.longitude, position.latitude, position.longitude);

      // ✅ 속도: 센서 speed 우선 + 없으면 계산값
      final sensedSpeed = position.speed; // m/s
      final bool sensedOk =
          sensedSpeed.isFinite && sensedSpeed > 0 && sensedSpeed <= maxHumanSpeedMps;
      final computedSpeed = d / rawDt;
      final usedSpeed = sensedOk ? sensedSpeed : computedSpeed;

      // ✅ 거리 유효성(점프 컷은 rawDt 기반 maxDistance로)
      final bool tooBigJump = d > maxDistance;
      final bool tooSmallMove = d < minDistance; // 🔥 단순화(흔들림은 거리로 컷)
      final bool isValidForAnchor = !tooBigJump && d >= 2.0; // anchor 갱신은 조금 더 관대하게
      final bool isValidForDistance = !tooSmallMove && !tooBigJump;


      // =========================
      // ✅ autoPause 판단 (⭐️ usedSpeed로!)
      // =========================
      final bool speedReliableForPause = (acc <= 20.0) && (d >= 3.0);
      final autoPauseSpeed = speedReliableForPause ? usedSpeed : computedSpeed;

      if (autoPauseSpeed < _autoPauseSpeedThreshold) {
        _lowSpeedSeconds += dt;
      } else {
        _lowSpeedSeconds = 0;
      }

      if (!_autoPaused && _lowSpeedSeconds >= _autoPauseSeconds) {
        _autoPaused = true;
        _resumeCandTicks = 0;
      } else if (_autoPaused) {
        final resumeSpeed = usedSpeed;

        final bool resumeCand = (acc <= 20.0) && (resumeSpeed >= 1.0) && (d >= 6.0) && !tooBigJump;

        if (resumeCand) {
          _resumeCandTicks += 1;
        } else {
          _resumeCandTicks = 0;
        }
        if (_resumeCandTicks >= 2) {
          _autoPaused = false;
          _lowSpeedSeconds = 0;
          _resumeCandTicks = 0;
        }
      }

      // =========================
      // ✅ lastPosition 갱신 정책 (핵심 변경)
      // - pause 중에도 anchor는 갱신한다 (거리 누적은 절대 X)
      // =========================
      if (_isPaused) {
        // pause 중: 기준점이 오래 고정되면, 나중에 d가 커져서 resume 오판이 잘 남
        // -> 점프만 아니면(anchor용) 갱신 허용
        if (isValidForAnchor && acc <= maxAccuracyM) {
          _lastPosition = position;
        }
      } else {
        // running 중: 유효한 이동만 거리 누적 + 기준점 갱신
        if (isValidForDistance && usedSpeed >= minSpeedMps) {
          _totalDistance += d;
          _segAccDist += d;
          _lastPosition = position;
        }
      }
    } else {
      _lastPosition = position;
    }

    final a = _elapsedSeconds > 0 ? _totalDistance / _elapsedSeconds : 0.0;

    // ✅ 1km 스플릿(보간)
    while (_segAccDist >= 1000.0) {
      final ratio = 1000.0 / _segAccDist;
      final segSeconds = (_segAccTime * ratio).round();

      _segIndex += 1;
      _segCumulativeSeconds += segSeconds;

      FlutterForegroundTask.sendDataToMain({
        'event': 'km',
        'km': _segIndex,
        'segSeconds': segSeconds,
        'cumulativeSeconds': _segCumulativeSeconds,
        'distanceMeters': _totalDistance,
        'elapsedSeconds': _elapsedSeconds,
        'avgSpeedMps': a,
        'isPaused': _isPaused,
      });

      _segAccDist -= 1000.0;
      _segAccTime -= segSeconds;
      if (_segAccTime < 0) _segAccTime = 0;
    }

    // =========================
    // ✅ tick 저장: 새 위치 + not paused 일 때만
    // =========================
    if (!_isPaused) {
      await db
          .into(db.runningTicks)
          .insert(
            RunningTicksCompanion.insert(
              ts: now,
              lat: position.latitude,
              lng: position.longitude,
              altitude: drift.Value(position.altitude),
              accuracy: drift.Value(position.accuracy),
              speedMps: drift.Value(a),
              isPaused: drift.Value(_isPaused),
            ),
          );
    }

    await flush(pos: position);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _posSub?.cancel();
    _posSub = null;
    // 세션 종료 처리, DB 저장 등 나중에 여기서
  }

  @override
  void onNotificationPressed() {
    // 알림 눌렀을 때 앱 열기
    FlutterForegroundTask.launchApp('/');
  }

  // ===== 내부 함수들 =====

  Future<bool> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return false;
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  void _sendFinalizeIfNeeded() {
    // 남은 구간 거리(km)
    final remainKm = _segAccDist / 1000.0;

    // 0.10km 이상이고 시간도 있어야 의미있음
    if (_segAccTime > 0) {
      FlutterForegroundTask.sendDataToMain({
        'event': 'finalize',
        'index': _segIndex + 1,
        'distanceKm': remainKm, // ✅ km 단위로 보냄
        'seconds': _segAccTime,
        'cumulativeSeconds': _segCumulativeSeconds + _segAccTime,
      });
    }
  }

  Future<AppDatabase> _getDb() async {
    if (_db != null) return _db!;
    // AppDatabase()가 내부에서 같은 파일(runmore.db)을 열어줌
    _db = AppDatabase();
    return _db!;
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double d) => d * pi / 180.0;

  String _formatElapsed(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    } else {
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
  }
}
