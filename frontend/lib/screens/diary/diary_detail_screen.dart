import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/emotion_utils.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tahsin_avatar.dart';
import '../../widgets/typing_text.dart';
import '../../widgets/shimmer_loading.dart';

class DiaryDetailScreen extends ConsumerWidget {
  const DiaryDetailScreen({super.key, required this.entryId});
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(diaryEntryProvider(entryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete entry?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(diaryRepositoryProvider).deleteEntry(entryId);
                ref.invalidate(diaryListProvider);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ParticleBackground(
        child: entryAsync.when(
          data: (entry) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(EmotionUtils.emojiFor(entry.primaryEmotion), style: const TextStyle(fontSize: 24)),
                        if (entry.moodSticker != null) ...[
                          const SizedBox(width: 8),
                          Text(entry.moodSticker!, style: const TextStyle(fontSize: 22)),
                        ],
                        const Spacer(),
                        Text(DateFormat('MMMM d, yyyy • h:mm a').format(entry.createdAt)),
                      ],
                    ),
                    if (entry.title != null && entry.title!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(entry.title!, style: Theme.of(context).textTheme.titleMedium),
                    ],
                    const SizedBox(height: 16),
                    Text(entry.content, style: const TextStyle(height: 1.6, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TahsinAvatar(size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tahsin', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pink)),
                          const SizedBox(height: 8),
                          TypingText(
                            text: entry.replyText ?? "I'm always here when you need me, Raisa. 💕",
                            style: TextStyle(height: 1.5, color: AppColors.pink.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: ShimmerLoading(height: 200),
          ),
          error: (e, _) => Center(child: Text('Could not load entry.\n$e')),
        ),
      ),
    );
  }
}
