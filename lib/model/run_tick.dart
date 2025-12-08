class RunTick {
  final DateTime ts;          // 측정이 찍힌 시간
  final double lat;           // 위도 (latitude)
  final double lng;           // 경도 (longitude)
  final double? altitude;     // 고도 (altitude, optional)
  final double speedMps;      // 순간 속도 (m/s)
  RunTick({
    required this.ts,
    required this.lat,
    required this.lng,
    this.altitude,
    required this.speedMps,
  });
}
