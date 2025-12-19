class LiveRunner {
  final String id;
  final String roomId;
  final String userId;
  final String displayName;
  final String? color;      // "#RRGGBB" 같은 문자열
  final bool isActive;
  final DateTime createdAt;
  final String? runId;
  final DateTime expiredAt;
  final int extendCount;

  LiveRunner({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.displayName,
    this.color,
    required this.isActive,
    required this.createdAt,
    this.runId,
    required this.expiredAt,
    required this.extendCount,
  });

  factory LiveRunner.fromJson(Map<String, dynamic> json) {
    return LiveRunner(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      color: json['color'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      runId: json['run_id'] as String?,
      expiredAt: DateTime.parse(json['expired_at'] as String),
      extendCount: json['extend_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'display_name': displayName,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'run_id': runId,
      'expired_at': expiredAt.toIso8601String(),
      'extend_count': extendCount,
    };
  }
}
