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
  // ১. ফ্লাটার বাইন্ডিং নিশ্চিত করছি
  WidgetsFlutterBinding.ensureInitialized();

  // ২. স্ট্যাটাস বার সেটআপ
  if (PlatformUtils.isMobile) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  // ৩. সার্ভিসগুলো ইনিশিয়ালাইজ করছি
  final offline = OfflineService();
  await offline.init();

  if (PlatformUtils.supportsLocalNotifications) {
    final notifications = LocalNotificationService();
    await notifications.init();
  }

  // ৪. অ্যাপ রান করছি এবং সার্ভিস ইনজেক্ট করছি
  runApp(
    ProviderScope(
      overrides: [
        offlineProvider.overrideWithValue(offline),
      ],
      child: const RaisaDiaryApp(),
    ),
  );
}

class RaisaDiaryApp extends ConsumerWidget {
  const RaisaDiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // এখানে প্রোভাইডার ওয়াচ করছি
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: "Jannatul Maowa Raisa's Diary",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      // ওয়েব এবং মোবাইল উভয়ের জন্য বিল্ডার
      builder: (context, child) {
        if (kIsWeb) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: child,
            ),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}