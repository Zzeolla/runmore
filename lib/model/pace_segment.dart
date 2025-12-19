import 'dart:convert';

class PaceSegment {
  final int index;       // 1km 구간 번호
  final double distance; // 이 구간의 km 수 (마지막 구간은 0.12km 같은 형태)
  final int seconds;     // 이 구간을 달린 시간(초)
  final int cumulativeSeconds; // 여기까지 누적 시간(초)
  PaceSegment({
    required this.index,
    required this.distance,
    required this.seconds,
    required this.cumulativeSeconds,
  });

  String get paceString {
    if (distance == 0) return '--';
    final pace = seconds / distance; // 초/km
    final m = (pace ~/ 60).toString();
    final s = (pace % 60).toInt().toString().padLeft(2, '0');
    return "$m'$s\"";
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'distance': distance,
    'seconds': seconds,
    'cumulativeSeconds': cumulativeSeconds,
  };

  factory PaceSegment.fromJson(Map<String, dynamic> json) => PaceSegment(
    index: json['index'] as int,
    distance: (json['distance'] as num).toDouble(),
    seconds: json['seconds'] as int,
    cumulativeSeconds: json['cumulativeSeconds'] as int,
  );
}