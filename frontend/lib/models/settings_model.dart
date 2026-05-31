class SettingsModel {
  SettingsModel({
    this.theme = 'system',
    this.fontFamily = 'Poppins',
    this.aiIntensity = 80,
    this.notificationsEnabled = true,
    this.backgroundMusic = false,
    this.biometricEnabled = false,
    this.hasPin = false,
    this.relationshipLevel = 1,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      theme: json['theme'] as String? ?? 'system',
      fontFamily: json['font_family'] as String? ?? 'Poppins',
      aiIntensity: json['ai_intensity'] as int? ?? 80,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      backgroundMusic: json['background_music'] as bool? ?? false,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      hasPin: json['has_pin'] as bool? ?? false,
      relationshipLevel: json['relationship_level'] as int? ?? 1,
    );
  }

  final String theme;
  final String fontFamily;
  final int aiIntensity;
  final bool notificationsEnabled;
  final bool backgroundMusic;
  final bool biometricEnabled;
  final bool hasPin;
  final int relationshipLevel;

  Map<String, dynamic> toUpdateJson() => {
        if (theme != 'system') 'theme': theme,
        'font_family': fontFamily,
        'ai_intensity': aiIntensity,
        'notifications_enabled': notificationsEnabled,
        'background_music': backgroundMusic,
        'biometric_enabled': biometricEnabled,
      };
}
