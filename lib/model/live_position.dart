class LivePosition {
  final int id;               // bigserial
  final String roomId;
  final String runnerId;
  final DateTime segmentTs;

  /// tick 배열 [{lat, lng, altitude, speed, heading, accuracy, ts}, ...]
  final List<Map<String, dynamic>> pathJson;

  final double distanceM;
  final int elapsedS;
  final int avgPaceSPerKm;
  final int currentPaceSPerKm;
  final DateTime createdAt;

  LivePosition({
    required this.id,
    required this.roomId,
    required this.runnerId,
    required this.segmentTs,
    required this.pathJson,
    required this.distanceM,
    required this.elapsedS,
    required this.avgPaceSPerKm,
    required this.currentPaceSPerKm,
    required this.createdAt,
  });

  static List<Map<String, dynamic>> _parseJsonbList(dynamic value) {
    if (value == null) return <Map<String, dynamic>>[];
    return (value as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  factory LivePosition.fromJson(Map<String, dynamic> json) {
    return LivePosition(
      id: (json['id'] as num).toInt(),
      roomId: json['room_id'] as String,
      runnerId: json['runner_id'] as String,
      segmentTs: DateTime.parse(json['segment_ts'] as String),
      pathJson: _parseJsonbList(json['path_json']),
      distanceM: (json['distance_m'] as num).toDouble(),
      elapsedS: json['elapsed_s'] as int,
      avgPaceSPerKm: json['avg_pace_s_per_km'] as int,
      currentPaceSPerKm: json['current_pace_s_per_km'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'runner_id': runnerId,
      'segment_ts': segmentTs.toIso8601String(),
      'path_json': pathJson,
      'distance_m': distanceM,
      'elapsed_s': elapsedS,
      'avg_pace_s_per_km': avgPaceSPerKm,
      'current_pace_s_per_km': currentPaceSPerKm,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
