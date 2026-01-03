import 'dart:async';
import 'dart:math';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runmore/db/app_database.dart';
import 'package:runmore/repository/local_run_repository.dart';

class RunTickEngine {
  Position? _lastAcceptedPos;

  // ===== 런 상태 =====
  double _totalDistance = 0.0; // m
  double _avgSpeedMps = 0.0;
  DateTime? _startedAt;
  int? _lastAcceptedPosTsMs;

  // auto pause
  bool _autoPaused = false;
  bool _userPaused = false;
  int _lowSpeedCount = 0;
  int _autoResumeCount = 0;

  bool get _isPaused => _autoPaused || _userPaused;

  // segment
  double _segAccDist = 0.0;
  int _segAccTimeMs = 0;
  int _segIndex = 0;
  int _segCumulativeMs = 0;

  // db
  AppDatabase? _db;
  LocalRunRepository? _repo;

  Timer? _secTimer;
  Stopwatch? _sw;
  int _elapsedBaseMs = 0;
  int _lastSentSecond = -1;

  bool _isRunning = false;

  // ===== 튜닝 =====
  static const double _autoPauseSpeedThreshold = 0.7; // m/s (~2.5km/h)
  static const int _autoPauseCounts = 2;

  int _elapsedMsNow() {
    final swMs = _sw?.elapsedMilliseconds ?? 0;
    return _elapsedBaseMs + swMs;
  }

  double avgSpeed() => _elapsedMsNow() > 0 ? _totalDistance / _elapsedMsNow() * 1000 : 0.0;

  Future<LocalRunRepository> _getRepo() async {
    if (_repo != null) return _repo!;
    final db = await _getDb();
    _repo = LocalRunRepository(db);
    return _repo!;
  }

  void resetForNewRun() {
    _startedAt = null;
    _lastAcceptedPos = null;
    _lastAcceptedPosTsMs = null;
    _totalDistance = 0.0;
    _avgSpeedMps = 0.0;
    _autoPaused = false;
    _userPaused = false;
    _lowSpeedCount = 0;
    _autoResumeCount = 0;

    _segAccDist = 0.0;
    _segAccTimeMs = 0;
    _segIndex = 0;
    _segCumulativeMs = 0;

    _elapsedBaseMs = 0;
    _lastSentSecond = -1;
    _sw?.stop();
    _sw = null;
  }

  void _startRun() {
    if (_isRunning) return;

    resetForNewRun(); // 원하면 여기서 초기화
    _isRunning = true;
    _secTimer?.cancel();

    final now = DateTime.now();
    _startedAt = now;

    _elapsedBaseMs = 0;
    _sw = Stopwatch()..start();
    _lastSentSecond = -1;

    _startSecondTimer();

    FlutterForegroundTask.sendDataToMain({
      'event': 'started',
      'startedAt': now.toIso8601String(),
    });
  }

  void _stopRun() async {
    if (!_isRunning) return;
    _isRunning = false;

    _secTimer?.cancel();
    _secTimer = null;

    // 최종 elapsed를 base에 반영
    _elapsedBaseMs = _elapsedMsNow();
    _sw?.stop();
    _sw = null;

    final repo = await _getRepo();
    await repo.clearTempRun();

    _sendState(event: 'stopped');
  }

  void _applyPauseState() {
    final paused = _isPaused;

    if (paused) {
      // stopwatch를 멈추고 base에 누적
      _elapsedBaseMs = _elapsedMsNow();
      _sw?.stop();
      _sw = null; // 🔥 핵심: swMs를 남기지 않는다
    } else {
      // 재개: stopwatch 새로 시작
      _sw ??= Stopwatch();
      _sw!
        ..reset()
        ..start();
    }

    FlutterForegroundTask.sendDataToMain({
      'event': 'pause_changed',
      'isPaused': paused,
      'autoPaused': _autoPaused,
      'userPaused': _userPaused,
      'elapsedSeconds': _elapsedMsNow() ~/ 1000,
    });
  }

  void _sendState({String event = 'state'}) {
    FlutterForegroundTask.sendDataToMain({
      'event': event,
      'distanceMeters': _totalDistance,
      'elapsedSeconds': _elapsedMsNow() ~/ 1000,
      'avgSpeedMps': _avgSpeedMps,
      'isPaused': _isPaused,
      'autoPaused': _autoPaused,
      'userPaused': _userPaused,
      'startedAt': _startedAt?.toIso8601String(),
    });
  }

  void onReceiveData(Object data) {
    if (data is! Map) return;
    final cmd = data['cmd'];

    if (cmd == 'pre_start') {

      return;
    }
    if (cmd == 'start_run') {
      _startRun();
      return;
    }

    if (cmd == 'pause') {
      _userPaused = true;
      _applyPauseState();
      return;
    }

    if (cmd == 'resume') {
      _userPaused = false;
      _autoPaused = false;
      _lowSpeedCount = 0;
      _applyPauseState();
      return;
    }

    if (cmd == 'stop') {
      _sendFinalizeIfNeeded();
      FlutterForegroundTask.sendDataToMain({'event': 'finalize_done'});
      _stopRun();
      return;
    }

    if (cmd == 'get_state') {
      _sendState();
      return;
    }
  }

  Future<void> alertState(int elapsedSecond) async {
    final elapsedText = _formatElapsed(elapsedSecond);
    final prefix = _isPaused ? '일시정지 중 ' : '';
    await FlutterForegroundTask.updateService(
      notificationTitle: '런모아 달리는 중',
      notificationText: '${(_totalDistance / 1000).toStringAsFixed(2)} km | $prefix$elapsedText',
    );
  }

  void _startSecondTimer() {
    _secTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_isRunning) return;

      // paused면 elapsed는 고정이지만, UI/알림 표시 일관성 위해 계속 전송해도 OK
      final elapsedMs = _elapsedMsNow();
      final sec = elapsedMs ~/ 1000;

      // 같은 초에 중복 전송 방지(가끔 Timer가 빠르게 2번 호출되는 케이스 방어)
      if (sec == _lastSentSecond) return;
      _lastSentSecond = sec;

      // ✅ 알림 업데이트 (삼성헬스처럼 “초” 맞추려면 여기서만!)
      await alertState(sec);

      // ✅ UI에 “1초 단위” 전송
      FlutterForegroundTask.sendDataToMain({
        'event': 'timer',
        'elapsedSeconds': sec,
        'distanceMeters': _totalDistance,
        'avgSpeedMps': _avgSpeedMps,
        'isPaused': _isPaused,
      });

      if (sec % 5 == 0) {
        final now = DateTime.now();
        final repo = await _getRepo();
        await repo.upsertRunningState(
          startedAt: _startedAt ?? now,
          lastTs: now,
          distanceMeters: _totalDistance,
          elapsedSeconds: sec,
          avgSpeedMps: _avgSpeedMps,
          isPaused: _isPaused,
        );
      }
    });
  }


  Future<void> onDestroy() async {
    _secTimer?.cancel();
    _secTimer = null;
    _sw?.stop();
    _sw = null;

    if (_repo != null) {
      await _repo!.clearTempRun();
    }

    // db를 열어놨으면 닫아줘도 됨(선택)
    await _db?.close();
    _db = null;
  }

  Future<bool> hasRequiredPermission({required bool isIOS}) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return false;
    }

    // iOS는 always가 사실상 필수
    if (isIOS) return perm == LocationPermission.always;

    // Android: 통일 강제면 always로 바꿔도 됨.
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  Future<void> processTick(Position? position) async {
    // position의 값이 들어온건지 판단
    if (position == null) {
      return;
    }
    if (!_isRunning) {
      _lastAcceptedPos = position;
      _lastAcceptedPosTsMs = position.timestamp.millisecondsSinceEpoch;
      return;
    }

    // ✅ 첫 위치가 “이제 막” 들어온 경우: 앵커만 잡고 종료
    if (_lastAcceptedPos == null || _lastAcceptedPosTsMs == null) {
      _lastAcceptedPos = position;
      _lastAcceptedPosTsMs = position.timestamp.millisecondsSinceEpoch;
      return;
    }

    // accuracy 판단
    const double maxAccuracyM = 25.0;
    final double acc = position.accuracy;
    if (!acc.isFinite || acc > maxAccuracyM) {
      return;
    }

    // position timestamp의 중복/역행 판단
    final posTsMs = position.timestamp.millisecondsSinceEpoch;
    final lastPosTsMs = _lastAcceptedPosTsMs;
    if (lastPosTsMs == null) {
      // 이 케이스는 원래 start에서 초기화됐어야 함.
      // 방어적으로만 처리
      _lastAcceptedPos = position;
      _lastAcceptedPosTsMs = posTsMs;
      return;
    }

    if (posTsMs <= lastPosTsMs) {
      return;
    }
    // 함수 시작
    final elapsedMs = _elapsedMsNow();

    final d = _haversine(_lastAcceptedPos!.latitude, _lastAcceptedPos!.longitude, position.latitude, position.longitude);

    // toobigjump 판단
    const double maxHumanSpeedMps = 8.0;
    final acceptedDtMs = posTsMs - lastPosTsMs;
    if (acceptedDtMs <= 0) {
      return;
    }

    final double maxDistance = max(30.0, maxHumanSpeedMps * acceptedDtMs / 1000 + 10.0);

    if (d > maxDistance) {
      return;
    }

    _lastAcceptedPos = position;
    _lastAcceptedPosTsMs = posTsMs;

    // autoPause/resume 판단(usedSpeed 우선)
    final beforePaused = _isPaused;

    if (!_userPaused) {
      final sensedSpeed = position.speed;
      final bool sensedOk =
          sensedSpeed.isFinite && sensedSpeed > 0 && sensedSpeed <= maxHumanSpeedMps;
      final computedSpeed = d / acceptedDtMs * 1000;
      final usedSpeed = sensedOk ? sensedSpeed : computedSpeed;

      if (usedSpeed < _autoPauseSpeedThreshold) {
        _lowSpeedCount += 1;
      } else {
        _lowSpeedCount = 0;
      }

      if (!_autoPaused && _lowSpeedCount >= _autoPauseCounts) {
        _autoPaused = true;
        _autoResumeCount = 0;
      } else if (_autoPaused) {
        if (usedSpeed >= _autoPauseSpeedThreshold) {
          _autoResumeCount += 1;
        } else {
          _autoResumeCount = 0;
        }
        if (_autoResumeCount >= 2) {
          _autoPaused = false;
          _lowSpeedCount = 0;
          _autoResumeCount = 0;
        }
      }
    }

    // pause 변경 여부 판단
    final afterPaused = _isPaused;

    if (afterPaused != beforePaused) {
      _applyPauseState();
    }

    if (!_isPaused) {
      _totalDistance += d;
      _segAccDist += d;
      _segAccTimeMs += acceptedDtMs;
      _avgSpeedMps = avgSpeed();

      final repo = await _getRepo();
      await repo.insertRunningTick(
        ts: position.timestamp,
        lat: position.latitude,
        lng: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speedMps: position.speed,
        // TODO: 나중에 심장박동, 케이던스 연동 필요
        hr: null,
        cadence: null,
        isPaused: _isPaused,
      );
    }

    // 1km 스플릿(보간)
    while (_segAccDist >= 1000.0) {
      final ratio = 1000.0 / _segAccDist;
      final segMs = (_segAccTimeMs * ratio).round();

      _segIndex += 1;
      _segCumulativeMs += segMs;

      FlutterForegroundTask.sendDataToMain({
        'event': 'seg',
        'km': _segIndex,
        'segSeconds': segMs ~/ 1000,
        'cumulativeSeconds': _segCumulativeMs ~/ 1000,
        'distanceMeters': _totalDistance,
        'elapsedSeconds': elapsedMs ~/ 1000,
        'avgSpeedMps': _avgSpeedMps,
        'isPaused': _isPaused,
      });

      _segAccDist -= 1000.0;
      _segAccTimeMs -= segMs;
      if (_segAccTimeMs < 0) _segAccTimeMs = 0;
    }

    // UI 전송
    FlutterForegroundTask.sendDataToMain({
      'ts': position.timestamp.toIso8601String(),
      'lat': position.latitude,
      'lng': position.longitude,
      'altitude': position.altitude,
      'accuracy': position.accuracy,
      'distanceMeters': _totalDistance,
      'elapsedSeconds': elapsedMs ~/ 1000,
      'avgSpeedMps': _avgSpeedMps,
      'isPaused': _isPaused,
    });
  }

  void sendDbg(String reason, {String? error}) {
    FlutterForegroundTask.sendDataToMain({
      'event': 'dbg',
      'reason': reason,
      if (error != null) 'error': error,
    });
  }

  void _sendFinalizeIfNeeded() {
    final remainKm = _segAccDist / 1000.0;
    if (_segAccTimeMs > 0) {
      FlutterForegroundTask.sendDataToMain({
        'event': 'finalize_segment',
        'index': _segIndex + 1,
        'distanceKm': remainKm,
        'seconds': _segAccTimeMs ~/ 1000,
        'cumulativeSeconds': (_segCumulativeMs + _segAccTimeMs) ~/ 1000,
      });
    }
  }

  Future<AppDatabase> _getDb() async {
    if (_db != null) return _db!;
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
