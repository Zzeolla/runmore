import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// ✅ 러닝(백그라운드 기록) 목적의 "통일 권한 플로우"
/// - 위치 서비스 OFF면 안내 (+ 설정 이동)
/// - denied면 권한 요청
/// - deniedForever면 설정 유도
/// - iOS: ALWAYS가 될 때까지 안내 + 설정 유도
/// - Android: whileInUse(앱 사용 중 허용)면 추가 팝업 없이 통과
Future<bool> ensureRunLocationPermissionWithUi(BuildContext context) async {
  // 1) 위치 서비스 ON?
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    final goSettings = await _showInfoDialog(
      context,
      title: '위치 서비스가 꺼져 있어요',
      message: '러닝 기록을 위해 위치 서비스를 켜야 합니다.\n설정에서 위치 서비스를 켜주세요.',
      showSettingsButton: true,
    );

    // Android는 위치 설정 화면 열기 지원
    // iOS는 위치 서비스 화면 직접 이동이 제한적이라 앱 설정만 열릴 수 있음
    if (goSettings) {
      try {
        await Geolocator.openLocationSettings();
      } catch (_) {}
    }
    return false;
  }

  // 2) 현재 권한 확인
  var perm = await Geolocator.checkPermission();

  // 3) denied면 1차 요청
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
  }

  // 4) deniedForever면 설정으로
  if (perm == LocationPermission.deniedForever) {
    final goSettings = await _showInfoDialog(
      context,
      title: '위치 권한이 필요해요',
      message: '설정에서 위치 권한을 허용해야 러닝 기록이 가능합니다.',
      showSettingsButton: true,
    );

    if (goSettings) {
      await Geolocator.openAppSettings();
    }
    return false;
  }

  // 5) 여기서부터 OS별 기준 처리
  if (Platform.isIOS) {
    // ✅ iOS: ALWAYS 필수(기존 정책 유지)
    if (perm != LocationPermission.always) {
      final go = await _showConfirmDialog(
        context,
        title: '백그라운드 기록 권한 필요',
        message: '화면이 꺼지거나 앱을 닫아도 러닝 기록을 계속하려면\n'
            '위치 권한을 “항상 허용”으로 설정해야 합니다.\n\n'
            '다음 권한 요청에서 “항상 허용”을 선택해주세요.',
        okText: '계속',
        cancelText: '취소',
      );
      if (go != true) return false;

      // iOS는 “Always”로 올라갈 기회를 주기 위해 다시 요청
      perm = await Geolocator.requestPermission();

      if (perm != LocationPermission.always) {
        final goSettings = await _showInfoDialog(
          context,
          title: '“항상 허용”이 아직 설정되지 않았어요',
          message: '설정 > 위치 > 런모아에서 “항상”으로 변경해주세요.',
          showSettingsButton: true,
        );
        if (goSettings) {
          await Geolocator.openAppSettings();
        }
        return false;
      }
    }
    return true;
  }

  // ✅ Android: whileInUse면 추가 UI 없이 바로 OK
  if (perm == LocationPermission.whileInUse ||
      perm == LocationPermission.always) {
    return true;
  }

  // 혹시 모를 예외 케이스(플러그인/OS 특이 상태)
  // 여기까지 왔다면 권한 재요청 한 번 더
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
    return perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
  }

  // 나머지는 안전하게 실패 처리
  return false;
}

Future<bool> _showInfoDialog(
    BuildContext context, {
      required String title,
      required String message,
      bool showSettingsButton = false,
    }) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('확인'),
        ),
        if (showSettingsButton)
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('설정'),
          ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool?> _showConfirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      required String okText,
      required String cancelText,
    }) async {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(okText),
        ),
      ],
    ),
  );
}
