import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:runmore/util/rest_headers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RunnerUploader {
  final String roomId;
  final String writeToken;

  RunnerUploader({required this.roomId, required this.writeToken});

  StreamSubscription<Position>? _sub;

  Future<void> start() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 필요합니다.');
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 3, // 3m 이동 시 갱신
      ),
    ).listen((pos) async {
      try {
        await withRestHeaders({'X-Write-Token': writeToken}, () async {
          await Supabase.instance.client
              .from('positions')
              .insert({
            'room_id': roomId,
            'lat': pos.latitude,
            'lng': pos.longitude,
            'speed': pos.speed,
            'heading': pos.heading,
            'accuracy': pos.accuracy,
            'ts': DateTime.now().toIso8601String(),
          });
        });
      } catch (e) {
        // TODO: 필요시 로깅 처리
        // TODO: 네트워크 중단 시 오프라인 큐(버퍼)에 쌓아두고 연결 복구
      }
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
