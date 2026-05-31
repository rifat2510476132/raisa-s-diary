class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.emailVerified = false,
    this.relationshipLevel = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalEntries = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? 'Raisa',
      avatarUrl: json['avatar_url'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      relationshipLevel: json['relationship_level'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalEntries: json['total_entries'] as int? ?? 0,
    );
  }

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool emailVerified;
  final int relationshipLevel;
  final int currentStreak;
  final int longestStreak;
  final int totalEntries;
}
