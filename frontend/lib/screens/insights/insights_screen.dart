import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/emotion_utils.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/emotion_bar_chart.dart';
import '../../widgets/mood_calendar_widget.dart';

final emotionStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(diaryRepositoryProvider).getEmotionStats(days: 30);
});

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(emotionStatsProvider);
    final now = DateTime.now();
    final calendar = ref.watch(moodCalendarProvider((year: now.year, month: now.month)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotional Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => context.push('/mood-calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.push('/achievements'),
          ),
        ],
      ),
      body: ParticleBackground(
        child: stats.when(
          data: (data) {
            final summary = (data['summary'] as List?) ?? [];
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(emotionStatsProvider);
                ref.invalidate(moodCalendarProvider((year: now.year, month: now.month)));
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  GlassCard(
                    child: SizedBox(
                      height: 220,
                      child: summary.isEmpty
                          ? const Center(child: Text('Write more to see your emotion graph 📊'))
                          : PieChart(
                              PieChartData(
                                sections: summary.asMap().entries.map((e) {
                                  final item = e.value as Map<String, dynamic>;
                                  final emotion = item['primary_emotion'] as String? ?? 'unknown';
                                  final count = int.tryParse(item['count'].toString()) ?? 1;
                                  return PieChartSectionData(
                                    value: count.toDouble(),
                                    title: EmotionUtils.emojiFor(emotion),
                                    color: EmotionUtils.colorFor(emotion, e.key),
                                    radius: 80,
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Emotion trends',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: SizedBox(
                      height: 200,
                      child: EmotionBarChart(summary: summary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'This month',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => context.push('/mood-calendar'),
                        child: const Text('Full calendar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  calendar.when(
                    data: (days) => GlassCard(
                      child: MoodCalendarWidget(
                        year: now.year,
                        month: now.month,
                        days: days,
                      ),
                    ),
                    loading: () => const GlassCard(child: LinearProgressIndicator()),
                    error: (_, __) => const GlassCard(
                      child: Text('Mood calendar loads when online.'),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Connect to backend to view insights.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(emotionStatsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
