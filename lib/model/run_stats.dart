class RunStats {
  final double distanceMeters;    // 누적 이동 거리 (m)
  final int elapsedSeconds;       // 경과 시간 (초)
  final double avgSpeedMps;       // 평균 속보 (m/s)
  final bool isPaused;           // 일시정지 여부
  const RunStats({
    required this.distanceMeters,
    required this.elapsedSeconds,
    required this.avgSpeedMps,
    this.isPaused = false,
  });

  double get paceSecPerKm => avgSpeedMps > 0 ? 1000.0 / avgSpeedMps : 0.0;

  /// "5'12\"" 이런 포맷으로 보고 싶을 때
  String get paceText {
    if (paceSecPerKm == 0) return '-';
    final total = paceSecPerKm.round();
    final min = total ~/ 60;
    final sec = total % 60;
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }

  RunStats copyWith({
    double? distanceMeters,
    int? elapsedSeconds,
    double? avgSpeedMps,
    bool? isPaused,
  }) {
    return RunStats(
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
