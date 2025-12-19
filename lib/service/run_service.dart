import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runmore/model/pace_segment.dart';
import 'package:runmore/model/run_stats.dart';
import 'package:runmore/model/run_tick.dart';
import 'package:runmore/service/foreground_run_service.dart';

class RunService {
  bool _isRunning = false;

  final _tickCtl = StreamController<RunTick>.broadcast();
  final _statsCtl = StreamController<RunStats>.broadcast();
  final _segmentCtl = StreamController<PaceSegment>.broadcast();
  final _pauseCtl = StreamController<Map<String, dynamic>>.broadcast();

  Completer<void>? _finalizeDoneCompleter;

  Stream<RunTick> get tickStream => _tickCtl.stream;
  Stream<RunStats> get statsStream => _statsCtl.stream;
  Stream<PaceSegment> get segmentStream => _segmentCtl.stream;
  Stream<Map<String, dynamic>> get pauseEventStream => _pauseCtl.stream;

  RunService() {
    // TaskHandler -> UI 로 오는 데이터를 받는 콜백 등록
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }
  // ===== 외부에서 쓰는 API =====
  bool get isRunning => _isRunning;

  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    _tickCtl.close();
    _statsCtl.close();
    _segmentCtl.close();
    _pauseCtl.close();
  }

  // ===== TaskHandler → UI 데이터 처리 =====
  void _onReceiveTaskData(Object data) {
    if (data is Map) {
      _handleBackgroundData(data.cast<String, dynamic>());
    }
  }

  void _handleBackgroundData(Map<String, dynamic> data) {
    final event = data['event'];

    if (event == 'km') {
      // kmStream (그냥 숫자도 계속 유지 가능)
      final kmVal = data['km'];
      final km = (kmVal is num) ? kmVal.toInt() : null;

      // ✅ segment도 같이 흘려보내기 (B안 payload에 segSeconds/cumulativeSeconds 있음)
      final segSecondsVal = data['segSeconds'];
      final cumVal = data['cumulativeSeconds'];

      if (km != null && segSecondsVal is num && cumVal is num) {
        _segmentCtl.add(
          PaceSegment(
            index: km,
            distance: 1.0,
            seconds: segSecondsVal.toInt(),
            cumulativeSeconds: cumVal.toInt(),
          ),
        );
      }
      return;
    }

    if (event == 'finalize') {
      final indexVal = data['index'];
      final distVal = data['distanceKm'];
      final secVal = data['seconds'];
      final cumVal = data['cumulativeSeconds'];

      if (indexVal is num && distVal is num && secVal is num && cumVal is num) {
        _segmentCtl.add(
          PaceSegment(
            index: indexVal.toInt(),
            distance: distVal.toDouble(),
            seconds: secVal.toInt(),
            cumulativeSeconds: cumVal.toInt(),
          ),
        );
      }
      return;
    }

    if (event == 'finalize_done') {
      _finalizeDoneCompleter?.complete();
      _finalizeDoneCompleter = null;
      return;
    }

    if (event == 'pause_changed' || event == 'auto_pause_changed') {
      _pauseCtl.add(data);
      return;
    }

    if (event == 'state') {
      final distanceMeters = (data['distanceMeters'] as num).toDouble();
      final elapsedSeconds = (data['elapsedSeconds'] as num).toInt();
      final isPaused = (data['isPaused'] as bool?) ?? false;

      final avgSpeedMps =
      elapsedSeconds > 0 ? distanceMeters / elapsedSeconds : 0.0;

      final stats = RunStats(
        distanceMeters: distanceMeters,
        elapsedSeconds: elapsedSeconds,
        avgSpeedMps: avgSpeedMps,
        isPaused: isPaused,
      );
      _statsCtl.add(stats);

      // (선택) pause 이벤트도 같이 흘려주면 UI/TTS가 더 자연스러움
      _pauseCtl.add({
        'event': 'pause_changed',
        'isPaused': isPaused,
        'autoPaused': data['autoPaused'] == true,
        'userPaused': data['userPaused'] == true,
      });

      return;
    }

    try {
      final ts = DateTime.parse(data['ts'] as String);
      final lat = (data['lat'] as num).toDouble();
      final lng = (data['lng'] as num).toDouble();
      final altitude = (data['altitude'] as num?)?.toDouble();
      final distanceMeters = (data['distanceMeters'] as num).toDouble();
      final elapsedSeconds = (data['elapsedSeconds'] as num).toInt();
      final avgSpeedMps = (data['avgSpeedMps'] as num).toDouble();
      final isPaused = (data['isPaused'] as bool?) ?? false;

      final tick = RunTick(
        ts: ts,
        lat: lat,
        lng: lng,
        altitude: altitude,
        speedMps: avgSpeedMps, // 나중에 순간 속도 별도 필드로 보내도 됨
        isPaused: isPaused,
      );
      _tickCtl.add(tick);

      final stats = RunStats(
        distanceMeters: distanceMeters,
        elapsedSeconds: elapsedSeconds,
        avgSpeedMps: avgSpeedMps,
        isPaused: isPaused,
      );
      _statsCtl.add(stats);
    } catch (_) {
      // 파싱 실패는 무시
    }
  }

  Future<bool> ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.deniedForever) return false;

    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    // 알림/배터리 최적화 예외 + ForegroundTask 초기화
    await ForegroundRunService.requestNotificationAndBatteryPermissions();
    await ForegroundRunService.initForegroundTask();

    // 포그라운드 서비스 시작 (백그라운드 위치 + 거리 계산 시작)
    await ForegroundRunService.startService();
  }

  Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;

    // ✅ finalize_done 기다릴 준비
    _finalizeDoneCompleter?.complete(); // 혹시 이전 잔여가 있으면 정리
    _finalizeDoneCompleter = Completer<void>();

    // 1) TaskHandler에 finalize 요청
    FlutterForegroundTask.sendDataToTask({'cmd': 'finalize'});

    // 2) finalize_done 올 때까지 기다리기 (무한대기는 위험하니 timeout)
    try {
      await _finalizeDoneCompleter!.future
          .timeout(const Duration(milliseconds: 1200));
    } catch (_) {
      // timeout이면 그냥 넘어감(기기/상황에 따라 이벤트 누락 방어)
    } finally {
      _finalizeDoneCompleter = null;
    }

    await ForegroundRunService.stopService();

    // 마지막으로 stats 한 번 흘려줄 수도 있음(0으로 초기화 등),
    // 지금은 그대로 두자.
  }

  // 기존 pause/resume은 일단 나중에 백그라운드랑 연결할 때 다시 설계
  void pause() {
    if (!_isRunning) return;
    // ForegroundTask(RunLocationTaskHandler) 쪽으로 명령 전송
    FlutterForegroundTask.sendDataToTask({
      'cmd': 'pause',
    });
  }

  void resume() {
    if (!_isRunning) return;
    FlutterForegroundTask.sendDataToTask({
      'cmd': 'resume',
    });
  }

  void requestState() {
    FlutterForegroundTask.sendDataToTask({'cmd': 'get_state'});
  }
}
