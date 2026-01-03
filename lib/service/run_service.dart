import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runmore/model/pace_segment.dart';
import 'package:runmore/model/run_stats.dart';
import 'package:runmore/model/run_tick.dart';
import 'package:runmore/service/foreground_run_service.dart';

class RunService {
  bool _isRunning = false;
  bool _runStarted = false;
  RunStats _lastStats = const RunStats(
    distanceMeters: 0,
    elapsedSeconds: 0,
    avgSpeedMps: 0,
    isPaused: false,
  );

  final _tickCtl = StreamController<RunTick>.broadcast();
  final _statsCtl = StreamController<RunStats>.broadcast();
  final _segmentCtl = StreamController<PaceSegment>.broadcast();
  final _pauseCtl = StreamController<Map<String, dynamic>>.broadcast();
  final _startedCtl = StreamController<DateTime>.broadcast();

  Completer<void>? _finalizeDoneCompleter;

  Stream<RunTick> get tickStream => _tickCtl.stream;
  Stream<RunStats> get statsStream => _statsCtl.stream;
  Stream<PaceSegment> get segmentStream => _segmentCtl.stream;
  Stream<Map<String, dynamic>> get pauseEventStream => _pauseCtl.stream;
  Stream<DateTime> get startedStream => _startedCtl.stream;


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
    _startedCtl.close();
  }

  // ===== TaskHandler → UI 데이터 처리 =====
  void _onReceiveTaskData(Object data) {
    if (data is Map) {
      _handleBackgroundData(data.cast<String, dynamic>());
    }
  }

  void _handleBackgroundData(Map<String, dynamic> data) {
    final event = data['event'];

    if (event == 'started') {
      _runStarted = true;
      final s = data['startedAt'];
      if (s is String) {
        final dt = DateTime.tryParse(s);
        if (dt != null) _startedCtl.add(dt);
      }
      return;
    }

    if (event == 'pause_changed') {
      _pauseCtl.add(data);

      final isPaused = data['isPaused'] == true;
      final stats = RunStats(
        distanceMeters: _lastStats.distanceMeters,
        elapsedSeconds: _lastStats.elapsedSeconds,
        avgSpeedMps: _lastStats.avgSpeedMps,
        isPaused: isPaused,
      );
      _lastStats = stats;
      _statsCtl.add(stats);

      return;
    }

    if (event == 'seg') {
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

    if (event == 'stopped') {

      return;
    }

    if (event == 'timer') {
      final distanceMeters = (data['distanceMeters'] as num).toDouble();
      final elapsedSeconds = (data['elapsedSeconds'] as num).toInt();
      final avgSpeedMps = (data['avgSpeedMps'] as num).toDouble();
      final isPaused = (data['isPaused'] as bool?) ?? false;
      final stats = RunStats(
        distanceMeters: distanceMeters,
        elapsedSeconds: elapsedSeconds,
        avgSpeedMps: avgSpeedMps,
        isPaused: isPaused,
      );
      _lastStats = stats;
      _statsCtl.add(stats);
      return;
    }

    if (event == 'finalize_segment') {
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
      _lastStats = stats;
      _statsCtl.add(stats);

      return;
    }

    try {
      final ts = DateTime.parse(data['ts'] as String);
      final lat = (data['lat'] as num).toDouble();
      final lng = (data['lng'] as num).toDouble();
      final altitude = (data['altitude'] as num?)?.toDouble();
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

  Future<void> preStart() async {
    if (_isRunning) return;

    try {
      // 알림/배터리 최적화 예외 + ForegroundTask 초기화
      await ForegroundRunService.requestNotificationAndBatteryPermissions();
      await ForegroundRunService.initForegroundTask();

      // 포그라운드 서비스 시작 (백그라운드 위치 + 거리 계산 시작)
      await ForegroundRunService.startService();
      _isRunning = true;
    } catch (e) {
      _isRunning = false;
      rethrow;
    }
  }

  Future<void> startRun() async {
    if (!_isRunning) return;
    FlutterForegroundTask.sendDataToTask({'cmd': 'start_run'});
  }

  Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;

    final running = await FlutterForegroundTask.isRunningService;

    if (running && _runStarted) {

      // ✅ finalize_done 기다릴 준비
      _finalizeDoneCompleter?.complete(); // 혹시 이전 잔여가 있으면 정리
      _finalizeDoneCompleter = Completer<void>();

      FlutterForegroundTask.sendDataToTask({'cmd': 'stop'});

      // 2) finalize_done 올 때까지 기다리기 (무한대기는 위험하니 timeout)
      try {
        await _finalizeDoneCompleter!.future
            .timeout(const Duration(milliseconds: 1200));
      } catch (_) {
        // timeout이면 그냥 넘어감(기기/상황에 따라 이벤트 누락 방어)
      } finally {
        _finalizeDoneCompleter = null;
      }
    }

    _runStarted = false;
    await ForegroundRunService.stopService();
  }

  // 기존 pause/resume은 일단 나중에 백그라운드랑 연결할 때 다시 설계
  void pause() {
    if (!_isRunning) return;
    FlutterForegroundTask.sendDataToTask({'cmd': 'pause'});
  }

  void resume() {
    if (!_isRunning) return;
    FlutterForegroundTask.sendDataToTask({'cmd': 'resume'});
  }

  void requestState() {
    FlutterForegroundTask.sendDataToTask({'cmd': 'get_state'});
  }
}
