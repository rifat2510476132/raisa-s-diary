import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/offline_service.dart';
import 'core/services/notification_service.dart';
import 'core/utils/platform_utils.dart';
import 'providers/providers.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformUtils.isMobile) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  final offline = OfflineService();
  await offline.init();

  if (PlatformUtils.supportsLocalNotifications) {
    final notifications = LocalNotificationService();
    await notifications.init();
  }

  runApp(
    ProviderScope(
      overrides: [offlineProvider.overrideWithValue(offline)],
      child: const RaisaDiaryApp(),
    ),
  );
}

class RaisaDiaryApp extends ConsumerWidget {
  const RaisaDiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: "Jannatul Maowa Raisa's Diary",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Web: center app like a phone frame on large screens
        if (kIsWeb) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
