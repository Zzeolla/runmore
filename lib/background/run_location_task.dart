import 'dart:io' show Platform;

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:runmore/background/run_location_task_android.dart';
import 'package:runmore/background/run_location_task_ios.dart';


@pragma('vm:entry-point') // 백그라운드에서 불리려면 꼭 필요
void runLocationStartCallback() {
  FlutterForegroundTask.setTaskHandler(
    Platform.isIOS ? RunLocationTaskHandlerIOS() : RunLocationTaskHandlerAndroid(),
  );
}
