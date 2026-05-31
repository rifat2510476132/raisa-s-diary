import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/haptic_service.dart';
import '../../core/utils/platform_utils.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    final aiIntensity = ref.watch(aiIntensityProvider);
    final audio = ref.watch(audioServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        data: (s) => ListView(
          children: [
            const _SectionHeader('Appearance'),
            SwitchListTile(
              title: const Text('Dark mode'),
              value: themeMode == ThemeMode.dark,
              onChanged: (v) {
                ref.read(themeModeProvider.notifier).setMode(v ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            const _SectionHeader('Experience'),
            SwitchListTile(
              title: const Text('Background music'),
              subtitle: const Text('Calm emotional ambience (add assets/audio/calm.mp3)'),
              value: s.backgroundMusic,
              onChanged: (v) async {
                await ref.read(settingsRepositoryProvider).updateSettings({'background_music': v});
                if (v) {
                  await audio.playCalmAmbience();
                } else {
                  await audio.stop();
                }
                ref.invalidate(settingsProvider);
              },
            ),
            ListTile(
              title: const Text('AI personality intensity'),
              subtitle: Slider(
                value: aiIntensity.toDouble(),
                min: 0,
                max: 100,
                activeColor: AppColors.pink,
                onChanged: (v) {
                  ref.read(aiIntensityProvider.notifier).state = v.round();
                },
                onChangeEnd: (v) async {
                  await ref.read(settingsRepositoryProvider).updateSettings({
                    'ai_intensity': v.round(),
                  });
                  ref.invalidate(settingsProvider);
                },
              ),
            ),
            const _SectionHeader('Security'),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('PIN Lock'),
              subtitle: Text(s.hasPin ? 'PIN is set' : 'No PIN set'),
              onTap: () => _showPinDialog(context, ref),
            ),
            if (PlatformUtils.supportsBiometrics)
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Biometric unlock'),
                subtitle: const Text('Fingerprint / Face'),
                onTap: () => context.push('/lock'),
              ),
            const _SectionHeader('Notifications'),
            SwitchListTile(
              title: const Text('Tahsin reminders'),
              subtitle: const Text('"Tahsin misses you 💌"'),
              value: s.notificationsEnabled,
              onChanged: (v) async {
                await ref.read(settingsRepositoryProvider).updateSettings({
                  'notifications_enabled': v,
                });
                if (v) {
                  await ref.read(localNotificationProvider).scheduleDailyReminder();
                }
                ref.invalidate(settingsProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Message inbox'),
              onTap: () => context.push('/notifications'),
            ),
            const _SectionHeader('Growth'),
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: const Text('Achievements'),
              onTap: () => context.push('/achievements'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Mood calendar'),
              onTap: () => context.push('/mood-calendar'),
            ),
            const _SectionHeader('Account'),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                "Jannatul Maowa Raisa's Diary\nv1.0.0 💕",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ListView(
          children: [
            const _SectionHeader('Offline mode'),
            SwitchListTile(
              title: const Text('Dark mode'),
              value: themeMode == ThemeMode.dark,
              onChanged: (v) {
                ref.read(themeModeProvider.notifier).setMode(v ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDialog(BuildContext context, WidgetRef ref) {
    final pin = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          controller: pin,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(hintText: '4-6 digit PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (pin.text.length < 4) return;
              await ref.read(settingsRepositoryProvider).setPin(pin.text);
              await HapticService.success();
              ref.invalidate(settingsProvider);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN saved securely')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.pink.withValues(alpha: 0.9),
          fontSize: 13,
        ),
      ),
    );
  }
}
