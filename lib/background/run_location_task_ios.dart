import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import 'run_tick_engine.dart';

class RunLocationTaskHandlerIOS extends TaskHandler {
  final RunTickEngine _engine = RunTickEngine();

  StreamSubscription<Position>? _posSub;
  Position? _latestPosition;

  // iOS: stream 콜백이 연속으로 들어오면 중첩 처리될 수 있어서 큐잉
  bool _handling = false;
  Position? _queued;

  @override
  void onReceiveData(Object data) {
    _engine.onReceiveData(data);
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _engine.resetForNewRun();

    final LocationSettings settings = AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // iOS는 0보다 5~10m가 노이즈/배터리 측면에서 유리한 경우가 많음
      pauseLocationUpdatesAutomatically: false, // 핵심: iOS 자동 중단 방지
      activityType: ActivityType.fitness, // 러닝 힌트
      showBackgroundLocationIndicator: true, // 심사/신뢰 + 안정성 도움
    );

    await _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
          (p) {
        _latestPosition = p;
        _enqueue(p); // ✅ B안 핵심: iOS는 "위치가 들어오는 순간" 처리
      },
      onError: (e) {
        _engine.sendDbg('pos_stream_error', error: '$e');
      },
      cancelOnError: false,
    );
  }

  void _enqueue(Position p) {
    if (_handling) {
      _queued = p; // 최신만 유지
      return;
    }
    _handling = true;

    Future.microtask(() async {
      try {
        final ok = await _engine.hasRequiredPermission(isIOS: true);
        if (ok) {
          await _engine.processTick(p);
        }
      } finally {
        _handling = false;
        final q = _queued;
        _queued = null;
        if (q != null) _enqueue(q);
      }
    });
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // iOS는 stream 기반이 메인이고, repeat은 "백업"
    final ok = await _engine.hasRequiredPermission(isIOS: true);
    if (!ok) return;

    await _engine.processTick(_latestPosition);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _posSub?.cancel();
    _posSub = null;
    await _engine.onDestroy();
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }
}
