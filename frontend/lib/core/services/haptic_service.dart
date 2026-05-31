import 'package:flutter/services.dart';

class HapticService {
  static Future<void> light() => HapticFeedback.lightImpact();
  static Future<void> medium() => HapticFeedback.mediumImpact();
  static Future<void> success() => HapticFeedback.selectionClick();
  static Future<void> warning() => HapticFeedback.heavyImpact();
}
