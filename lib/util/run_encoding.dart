// lib/util/run_encoding.dart
import 'dart:convert';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:runmore/model/pace_segment.dart';

String encodePath(List<NLatLng> path) {
  final list = path
      .map((p) => {
    'lat': p.latitude,
    'lng': p.longitude,
  })
      .toList();
  return jsonEncode(list);
}

List<NLatLng> decodePath(String jsonStr) {
  final list = (jsonDecode(jsonStr) as List)
      .map((e) => NLatLng(
    (e['lat'] as num).toDouble(),
    (e['lng'] as num).toDouble(),
  ))
      .toList();
  return list;
}

// segments는 PaceSegment에 toJson/fromJson 만들어 두고 사용
String encodeSegments(List<PaceSegment> segments) {
  return jsonEncode(segments.map((s) => s.toJson()).toList());
}

List<PaceSegment> decodeSegments(String jsonStr) {
  final list = jsonDecode(jsonStr) as List;
  return list
      .map((e) => PaceSegment.fromJson(e as Map<String, dynamic>))
      .toList();
}
