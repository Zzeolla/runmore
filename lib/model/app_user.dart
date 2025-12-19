class AppUser {
  final String id;        // app_users PK (uuid)
  final String nickname;
  final DateTime createdAt;
  final String? coverUrl;

  AppUser({
    required this.id,
    required this.nickname,
    required this.createdAt,
    this.coverUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      coverUrl: json['cover_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'created_at': createdAt.toIso8601String(),
      'cover_url': coverUrl,
    };
  }
}
