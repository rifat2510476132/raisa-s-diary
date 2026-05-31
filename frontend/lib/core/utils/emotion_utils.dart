import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmotionUtils {
  static String emojiFor(String? emotion) {
    return switch (emotion?.toLowerCase()) {
      'happy' => '😊',
      'sad' => '😢',
      'angry' => '😠',
      'lonely' => '🥺',
      'motivated' => '💪',
      'depressed' => '🌧️',
      'romantic' => '💕',
      'stressed' => '😰',
      'neutral' => '✨',
      _ => '💭',
    };
  }

  static Color colorFor(String? emotion, int index) {
    const palette = [
      AppColors.pink,
      AppColors.rose,
      Color(0xFFFFB6C1),
      Color(0xFFE1BEE7),
      Color(0xFFB39DDB),
      Color(0xFF90CAF9),
      Color(0xFF80CBC4),
      Color(0xFFFFCC80),
    ];
    if (emotion == null) return palette[index % palette.length];
    final hash = emotion.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  static String labelFor(String? emotion) {
    if (emotion == null) return 'Unknown';
    return emotion[0].toUpperCase() + emotion.substring(1);
  }
}
