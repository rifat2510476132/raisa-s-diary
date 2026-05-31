class AchievementModel {
  AchievementModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.icon = '🏆',
    this.unlockedAt,
    this.progress = 0,
    this.target = 1,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String? ?? json['code'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏆',
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'] as String)
          : null,
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int? ?? 1,
    );
  }

  final String id;
  final String code;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  bool get isUnlocked => unlockedAt != null;
}
