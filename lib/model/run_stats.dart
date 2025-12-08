class RunStats {
  final double distanceMeters;    // 누적 이동 거리 (m)
  final int elapsedSeconds;       // 경과 시간 (초)
  final double avgSpeedMps;       // 평균 속보 (m/s)
  const RunStats({
    required this.distanceMeters,
    required this.elapsedSeconds,
    required this.avgSpeedMps,
  });
}
