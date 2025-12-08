import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:runmore/util/rest_headers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewerPoller {
  final String shareCode;
  final String roomId;

  ViewerPoller({required this.shareCode, required this.roomId});

  Timer? _timer;
  final ValueNotifier<List<Map<String, dynamic>>> positions =
  ValueNotifier<List<Map<String, dynamic>>>([]);

  void start() {
    // 2초마다 최신 200개 좌표 불러오기
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final rows = await withRestHeaders({'X-Share-Code': shareCode}, () async {
        final res = await Supabase.instance.client
            .from('positions')
            .select('lat,lng,ts,speed,heading,accuracy')
            .eq('room_id', roomId)
            .order('ts', ascending: true)
            .limit(200);
        return res;
      });
      positions.value = List<Map<String, dynamic>>.from(rows);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
