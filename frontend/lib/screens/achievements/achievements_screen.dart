import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/empty_state.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emotional Achievements')),
      body: ParticleBackground(
        child: achievements.when(
          data: (list) {
            if (list.isEmpty) {
              return const EmptyState(
                emoji: '🏆',
                title: 'Achievements unlock as you grow',
                subtitle: 'Keep writing — Tahsin is proud of every step.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final a = list[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    child: Row(
                      children: [
                        Text(a.icon, style: TextStyle(fontSize: 36, color: a.isUnlocked ? null : Colors.grey)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: a.isUnlocked ? null : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(a.description, style: const TextStyle(fontSize: 13, height: 1.3)),
                              if (!a.isUnlocked) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: a.target > 0 ? a.progress / a.target : 0,
                                  backgroundColor: AppColors.pink.withValues(alpha: 0.1),
                                  color: AppColors.pink,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (a.isUnlocked) const Icon(Icons.check_circle, color: AppColors.pink),
                      ],
                    ),
                  ).animate().fadeIn(delay: (i * 80).ms),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const EmptyState(
            emoji: '📡',
            title: 'Connect to load achievements',
            subtitle: 'Your progress syncs when you\'re online.',
          ),
        ),
      ),
    );
  }
}
