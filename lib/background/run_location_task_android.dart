import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import 'run_tick_engine.dart';

class RunLocationTaskHandlerAndroid extends TaskHandler {
  final RunTickEngine _engine = RunTickEngine();

  StreamSubscription<Position>? _posSub;
  Position? _latestPosition;

  @override
  void onReceiveData(Object data) {
    _engine.onReceiveData(data);
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final LocationSettings settings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      intervalDuration: const Duration(seconds: 1),
    );

    await _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
          (p) {
        _latestPosition = p;
      },
      onError: (e) {
        _engine.sendDbg('pos_stream_error', error: '$e');
      },
      cancelOnError: false,
    );

    FlutterForegroundTask.sendDataToMain({
      'event': 'service_started',
      'ts': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // 권한/서비스 체크
    final ok = await _engine.hasRequiredPermission(isIOS: false);
    if (!ok) return;

    // Android는 기존처럼 "1초 폴링" 기반으로 처리
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
