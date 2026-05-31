import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/haptic_service.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('From Tahsin'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
            },
            child: const Text('Read all'),
          ),
        ],
      ),
      body: ParticleBackground(
        child: notifications.when(
          data: (list) {
            if (list.isEmpty) {
              return const EmptyState(
                emoji: '💌',
                title: 'No messages yet',
                subtitle: 'Tahsin will send you loving reminders here.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(notificationsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final n = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      onTap: () async {
                        if (!n.isRead) {
                          await HapticService.light();
                          await ref.read(notificationRepositoryProvider).markRead(n.id);
                          ref.invalidate(notificationsProvider);
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!n.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              decoration: const BoxDecoration(
                                color: AppColors.pink,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(n.body, style: const TextStyle(height: 1.4)),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('MMM d, h:mm a').format(n.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const EmptyState(
            emoji: '📡',
            title: 'Offline',
            subtitle: 'Connect to see Tahsin\'s messages.',
          ),
        ),
      ),
    );
  }
}
