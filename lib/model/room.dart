class Room {
  final String id;
  final String title;
  final String shareCode;
  final String writeToken;
  final bool isActive;
  final String? createdBy;      // nullable
  final DateTime createdAt;
  final DateTime expiredAt;
  final int extendCount;

  Room({
    required this.id,
    required this.title,
    required this.shareCode,
    required this.writeToken,
    required this.isActive,
    required this.createdAt,
    required this.expiredAt,
    this.createdBy,
    required this.extendCount,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      title: json['title'] as String,
      shareCode: json['share_code'] as String,
      writeToken: json['write_token'] as String,
      isActive: json['is_active'] as bool,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiredAt: DateTime.parse(json['expired_at'] as String),
      extendCount: json['extend_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'share_code': shareCode,
      'write_token': writeToken,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'expired_at': expiredAt.toIso8601String(),
      'extend_count': extendCount,
    };
  }
}
