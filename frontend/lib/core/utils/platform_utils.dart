import 'package:flutter/foundation.dart';

/// Web vs mobile helpers (Netlify / APK).
class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb;
  static bool get supportsBiometrics => !kIsWeb;
  static bool get supportsLocalNotifications => !kIsWeb;
}
