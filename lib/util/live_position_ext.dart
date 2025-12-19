import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:runmore/model/live_position.dart';

extension LivePositionPolylineX on LivePosition {
  List<NLatLng> get polylinePoints {
    return pathJson
        .map((e) => NLatLng(
      (e['lat'] as num).toDouble(),
      (e['lng'] as num).toDouble(),
    ))
        .toList();
  }

  NLatLng? get lastPoint {
    if (pathJson.isEmpty) return null;
    final last = pathJson.last;
    return NLatLng(
      (last['lat'] as num).toDouble(),
      (last['lng'] as num).toDouble(),
    );
  }
}
