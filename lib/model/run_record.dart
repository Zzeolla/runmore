class RunRecord {
  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime endedAt;

  final double distanceM;
  final int elapsedS;
  final double avgSpeedMps;
  final int? calories;
  final int? avgHr;
  final int? avgCadence;

  /// path_json: GPS tick 배열 등 (JSONB)
  /// [{lat, lng, altitude, speed, heading, accuracy, ts}, ...] 형태라고 가정
  final List<Map<String, dynamic>> pathJson;

  /// segments_json: 페이스 구간 정보 배열 (JSONB)
  final List<Map<String, dynamic>> segmentsJson;

  final String? liveRoomId;
  final DateTime createdAt;

  RunRecord({
    required this.id,
    required this.userId,
    required this.startedAt,
    required this.endedAt,
    required this.distanceM,
    required this.elapsedS,
    required this.avgSpeedMps,
    this.calories,
    this.avgHr,
    this.avgCadence,
    required this.pathJson,
    required this.segmentsJson,
    this.liveRoomId,
    required this.createdAt,
  });

  static List<Map<String, dynamic>> _parseJsonbList(dynamic value) {
    if (value == null) return <Map<String, dynamic>>[];
    // Supabase jsonb -> List<dynamic> -> List<Map<String, dynamic>>
    return (value as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  factory RunRecord.fromJson(Map<String, dynamic> json) {
    return RunRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: DateTime.parse(json['ended_at'] as String),
      distanceM: (json['distance_m'] as num).toDouble(),
      elapsedS: json['elapsed_s'] as int,
      avgSpeedMps: (json['avg_speed_mps'] as num).toDouble(),
      calories: json['calories'] as int?,
      avgHr: json['avg_hr'] as int?,
      avgCadence: json['avg_cadence'] as int?,
      pathJson: _parseJsonbList(json['path_json']),
      segmentsJson: _parseJsonbList(json['segments_json']),
      liveRoomId: json['live_room_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
      'distance_m': distanceM,
      'elapsed_s': elapsedS,
      'avg_speed_mps': avgSpeedMps,
      'calories': calories,
      'avg_hr': avgHr,
      'avg_cadence': avgCadence,
      'path_json': pathJson,
      'segments_json': segmentsJson,
      'live_room_id': liveRoomId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}