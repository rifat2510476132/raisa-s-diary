import '../utils/platform_utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (!PlatformUtils.supportsLocalNotifications) return;
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) {},
    );
    _initialized = true;
  }

  Future<void> showTahsinReminder({
    required String title,
    required String body,
  }) async {
    if (!PlatformUtils.supportsLocalNotifications) return;
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'tahsin_channel',
        'Tahsin Reminders',
        channelDescription: 'Loving reminders from Tahsin',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleDailyReminder() async {
    await showTahsinReminder(
      title: 'Tahsin misses you 💌',
      body: 'Write your feelings today, Raisa.',
    );
  }
}
