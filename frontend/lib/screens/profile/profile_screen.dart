import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/relationship_badge.dart';
import '../../widgets/tahsin_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final user = await ref.read(userRepositoryProvider).updateProfile(displayName: name);
      ref.read(authStateProvider.notifier).checkAuth();
      if (mounted) {
        setState(() {
          _editing = false;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hello, ${user.displayName}! 🌸')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final user = auth?.user;

    if (user != null && !_editing && _nameController.text.isEmpty) {
      _nameController.text = user.displayName;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: ParticleBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.pink.withValues(alpha: 0.3),
                    child: Text(
                      (user?.displayName ?? 'R').substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.pink),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_editing)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Display name'),
                          ),
                        ),
                        IconButton(
                          onPressed: _saving ? null : _saveName,
                          icon: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                        ),
                      ],
                    )
                  else
                    Text(
                      user?.displayName ?? 'Raisa',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),
                  Text(user?.email ?? '', style: TextStyle(color: Theme.of(context).hintColor)),
                  const SizedBox(height: 12),
                  if (user != null) RelationshipBadge(level: user.relationshipLevel),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                children: [
                  _StatRow(label: 'Writing streak', value: '${user?.currentStreak ?? 0} days 🔥'),
                  const Divider(height: 24),
                  _StatRow(label: 'Longest streak', value: '${user?.longestStreak ?? 0} days'),
                  const Divider(height: 24),
                  _StatRow(label: 'Total entries', value: '${user?.totalEntries ?? 0}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const TahsinAvatar(size: 56, pulsing: false),
            const SizedBox(height: 8),
            const Text(
              'Your bond with Tahsin grows with every entry 💕',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _MenuTile(
              icon: Icons.chat_bubble_outline,
              title: 'Chat with Tahsin',
              onTap: () => context.push('/ai-chat'),
            ),
            _MenuTile(
              icon: Icons.menu_book_outlined,
              title: 'Diary history',
              onTap: () => context.push('/diaries'),
            ),
            _MenuTile(
              icon: Icons.calendar_month_outlined,
              title: 'Mood calendar',
              onTap: () => context.push('/mood-calendar'),
            ),
            _MenuTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push('/notifications'),
            ),
            _MenuTile(
              icon: Icons.emoji_events_outlined,
              title: 'Achievements',
              onTap: () => context.push('/achievements'),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.pink)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.pink),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
