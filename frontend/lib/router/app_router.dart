import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/diary/write_diary_screen.dart';
import '../screens/diary/diary_detail_screen.dart';
import '../screens/diary/diary_list_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/lock/lock_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/calendar/mood_calendar_screen.dart';
import '../screens/ai/ai_chat_screen.dart';
import '../screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final loc = state.matchedLocation;
      final isAuthRoute = loc.startsWith('/login') ||
          loc.startsWith('/register') ||
          loc.startsWith('/forgot');
      final isPublic = loc == '/splash' || loc.startsWith('/onboarding');

      if (auth.isLoading) return null;

      final loggedIn = auth.valueOrNull?.isAuthenticated ?? false;

      if (!loggedIn && !isAuthRoute && !isPublic) return '/login';
      if (loggedIn && (isAuthRoute || loc == '/splash')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/lock', builder: (_, __) => const LockScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
      GoRoute(path: '/write', builder: (_, __) => const WriteDiaryScreen()),
      GoRoute(path: '/diary-editor', builder: (_, __) => const WriteDiaryScreen()),
      GoRoute(path: '/diaries', builder: (_, __) => const DiaryListScreen()),
      GoRoute(path: '/diary-history', builder: (_, __) => const DiaryListScreen()),
      GoRoute(path: '/ai-chat', builder: (_, __) => const AiChatScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
        path: '/diary/:id',
        builder: (_, state) => DiaryDetailScreen(entryId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/insights', builder: (_, __) => const InsightsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/achievements', builder: (_, __) => const AchievementsScreen()),
      GoRoute(path: '/mood-calendar', builder: (_, __) => const MoodCalendarScreen()),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
