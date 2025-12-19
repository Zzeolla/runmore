import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:runmore/background/run_location_task.dart';

class ForegroundRunService {
  static Future<void> requestNotificationAndBatteryPermissions() async {
    final notificationPermission =
    await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
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
    final perm =
    await FlutterForegroundTask.checkNotificationPermission();

    if (perm != NotificationPermission.granted) {
      // ❗ 여기서 return
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
  // TODO: 앱을 껐을 경우를 대비해 알람에도 종료 추가해주기
  static Future<void> stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}
