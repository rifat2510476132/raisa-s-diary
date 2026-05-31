import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tahsin_avatar.dart';
import '../../widgets/relationship_badge.dart';
import '../../widgets/motivation_quote_card.dart';
import '../../models/diary_entry_model.dart';

final tahsinMessageProvider = FutureProvider.autoDispose<String>((ref) async {
  return ref.watch(diaryRepositoryProvider).getTahsinMessage();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final user = auth?.user;
    final tahsinMsg = ref.watch(tahsinMessageProvider);
    final diaries = ref.watch(diaryListProvider);

    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(diaryListProvider);
              ref.invalidate(tahsinMessageProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${user?.displayName ?? 'Raisa'} 🌸',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                DateFormat('EEEE, MMM d').format(DateTime.now()),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () => context.push('/ai-chat'),
                          tooltip: 'Chat with Tahsin',
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => context.push('/notifications'),
                        ),
                        _StreakBadge(streak: user?.currentStreak ?? 0),
                      ],
                    ),
                  ),
                ),
                if (user != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RelationshipBadge(level: user.relationshipLevel),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: tahsinMsg.when(
                      data: (msg) => _TahsinMessageCard(message: msg),
                      loading: () => const GlassCard(child: LinearProgressIndicator()),
                      error: (_, __) => const GlassCard(
                        child: Text('Tahsin misses you 💌 Write your feelings today.'),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.05),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: MotivationQuoteCard(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _QuickMoodCard(emoji: '😊', label: 'Happy')),
                        const SizedBox(width: 12),
                        Expanded(child: _QuickMoodCard(emoji: '😢', label: 'Sad')),
                        const SizedBox(width: 12),
                        Expanded(child: _QuickMoodCard(emoji: '💕', label: 'Love')),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Diaries',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => context.push('/diaries'),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                  ),
                ),
                diaries.when(
                  data: (entries) => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i >= entries.length) return null;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: _DiaryCard(entry: entries[i]),
                        );
                      },
                      childCount: entries.isEmpty ? 0 : entries.length.clamp(0, 5),
                    ),
                  ),
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: GlassCard(child: Text('Connect to server to sync diaries.\n$e')),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pink.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text('$streak', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pink)),
        ],
      ),
    );
  }
}

class _TahsinMessageCard extends StatelessWidget {
  const _TahsinMessageCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TahsinAvatar(size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tahsin says', style: TextStyle(fontSize: 12, color: AppColors.pink.withValues(alpha: 0.8))),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickMoodCard extends StatelessWidget {
  const _QuickMoodCard({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      onTap: () => context.push('/write'),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({required this.entry});
  final DiaryEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/diary/${entry.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (entry.primaryEmotion != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(entry.primaryEmotion!, style: const TextStyle(fontSize: 11)),
                ),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (entry.replyText != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tahsin: ${entry.replyText}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.pink.withValues(alpha: 0.9)),
            ),
          ],
        ],
      ),
    );
  }
}
