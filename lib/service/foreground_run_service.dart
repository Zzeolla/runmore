import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:runmore/background/run_location_task.dart';

class ForegroundRunService {
  static bool _init = false;

  static Future<void> requestNotificationAndBatteryPermissions() async {
    final notificationPermission = await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      final ignoring = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!ignoring) {
        // 여기서 안내 UI(다이얼로그) 띄우고
        // 사용자가 "설정으로 이동" 누르면 아래 호출
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  static Future<void> initForegroundTask() async {
    if (_init) return;
    _init = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'runmore_foreground',
        channelName: '런모아 러닝 추적',
        channelDescription: '러닝 중일 때 표시되는 알림 채널입니다.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startService() async {
    final perm = await FlutterForegroundTask.checkNotificationPermission();

    if (perm != NotificationPermission.granted) {
      // TODO: UI(run_screen)에서 예외 잡아줘야 함
      throw Exception('알림 권한이 필요합니다');
    }

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
      return;
    }

    await FlutterForegroundTask.startService(
      serviceId: 100,
      notificationTitle: '런모아 달리는 중',
      notificationText: '준비 중...',
      notificationInitialRoute: '/',
      callback: runLocationStartCallback,
    );
  }


  static Future<void> stopService() async {
    // TODO: 앱을 껐을 경우를 대비해 알람에도 종료 추가해주기
    // TODO: 앱이 백그라운드 갔다가 다시 들어오면 화면 재진입 이걸 restartservicce로 처리하려고 하는데, 이게 내부 변수들 초기값으로 리셋될 수 있대, 잘 이해가 안가긴 하지만 나중에 체크해보자
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
    return;
  }
}
