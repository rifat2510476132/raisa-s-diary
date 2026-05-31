import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_client.dart';
import '../core/services/audio_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/offline_service.dart';
import '../models/diary_entry_model.dart';
import '../models/notification_model.dart';
import '../models/settings_model.dart';
import '../models/achievement_model.dart';
import '../models/mood_calendar_day.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/diary_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/media_repository.dart';
import '../repositories/ai_chat_repository.dart';
import '../repositories/user_repository.dart';

final storageProvider = Provider((ref) => StorageService());
final apiClientProvider = Provider((ref) => ApiClient(ref.watch(storageProvider)));
final offlineProvider = Provider((ref) => OfflineService());
final audioServiceProvider = Provider((ref) => AudioService());
final localNotificationProvider = Provider((ref) => LocalNotificationService());

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(storageProvider)),
);
final diaryRepositoryProvider = Provider(
  (ref) => DiaryRepository(ref.watch(apiClientProvider), ref.watch(offlineProvider)),
);
final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(ref.watch(apiClientProvider)),
);
final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(apiClientProvider)),
);
final mediaRepositoryProvider = Provider(
  (ref) => MediaRepository(ref.watch(storageProvider)),
);
final aiChatRepositoryProvider = Provider(
  (ref) => AiChatRepository(ref.watch(apiClientProvider)),
);
final userRepositoryProvider = Provider(
  (ref) => UserRepository(ref.watch(apiClientProvider)),
);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(storageProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _load();
  }
  final StorageService _storage;

  Future<void> _load() async {
    final mode = await _storage.getThemeMode();
    state = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final key = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _storage.setThemeMode(key);
  }
}

class UserSession {
  UserSession({this.user, required this.isAuthenticated});
  final UserModel? user;
  final bool isAuthenticated;
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserSession>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<UserSession>> {
  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    checkAuth();
  }
  final AuthRepository _repo;

  Future<void> checkAuth() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.getProfile();
      state = AsyncValue.data(UserSession(user: user, isAuthenticated: true));
    } catch (_) {
      state = AsyncValue.data(UserSession(user: null, isAuthenticated: false));
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final user = await _repo.login(email, password);
    state = AsyncValue.data(UserSession(user: user, isAuthenticated: true));
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncValue.loading();
    final user = await _repo.register(email, password, name);
    state = AsyncValue.data(UserSession(user: user, isAuthenticated: true));
  }

  Future<void> logout() async {
    await _repo.logout();
    state = AsyncValue.data(UserSession(user: null, isAuthenticated: false));
  }
}

final diaryListProvider = FutureProvider.autoDispose<List<DiaryEntryModel>>((ref) async {
  return ref.watch(diaryRepositoryProvider).getEntries();
});

final diaryEntryProvider = FutureProvider.autoDispose.family<DiaryEntryModel, String>((ref, id) async {
  return ref.watch(diaryRepositoryProvider).getEntry(id);
});

final notificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});

final settingsProvider = FutureProvider.autoDispose<SettingsModel>((ref) async {
  return ref.watch(settingsRepositoryProvider).getSettings();
});

final achievementsProvider = FutureProvider.autoDispose<List<AchievementModel>>((ref) async {
  return ref.watch(settingsRepositoryProvider).getAchievements();
});

final moodCalendarProvider = FutureProvider.autoDispose
    .family<List<MoodCalendarDay>, ({int year, int month})>((ref, params) async {
  final raw = await ref.watch(diaryRepositoryProvider).getMoodCalendar(params.year, params.month);
  return raw.map((e) => MoodCalendarDay.fromJson(e as Map<String, dynamic>)).toList();
});

final aiIntensityProvider = StateProvider<int>((ref) => 80);
