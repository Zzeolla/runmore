class RunTick {
  final DateTime ts;          // 측정이 찍힌 시간
  final double lat;           // 위도 (latitude)
  final double lng;           // 경도 (longitude)
  final double? altitude;     // 고도 (altitude, optional)
  final double speedMps;      // 순간 속도 (m/s)
  final int? hr;
  final int? cadence;
  final bool isPaused;
  RunTick({
    required this.ts,
    required this.lat,
    required this.lng,
    this.altitude,
    required this.speedMps,
    this.hr,
    this.cadence,
    required this.isPaused,
  });
}

extension RunTickJson on RunTick {
  Map<String, dynamic> toJson() => {
    'ts': ts.toUtc().toIso8601String(),
    'lat': lat,
    'lng': lng,
    if (altitude != null) 'altitude': altitude,
    'speed': speedMps,
    if (hr != null) 'hr': hr,
    if (cadence != null) 'cadence': cadence,
    'isPaused': isPaused,
  };
}