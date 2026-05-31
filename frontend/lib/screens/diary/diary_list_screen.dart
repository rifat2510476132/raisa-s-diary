import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/diary_list_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loading.dart';

class DiaryListScreen extends ConsumerWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaries = ref.watch(diaryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Diaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/write'),
          ),
        ],
      ),
      body: ParticleBackground(
        child: diaries.when(
          data: (entries) {
            if (entries.isEmpty) {
              return EmptyState(
                emoji: '📔',
                title: 'Your diary is waiting',
                subtitle: 'Pour your heart out — Tahsin is listening.',
                actionLabel: 'Write now',
                onAction: () => context.push('/write'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(diaryListProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => DiaryListTile(
                  entry: entries[i],
                  onTap: () => context.push('/diary/${entries[i].id}'),
                ),
              ),
            );
          },
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              ShimmerLoading(height: 120),
              SizedBox(height: 12),
              ShimmerLoading(height: 120),
              SizedBox(height: 12),
              ShimmerLoading(height: 120),
            ],
          ),
          error: (e, _) => ErrorState(message: e.toString()),
        ),
      ),
    );
  }
}
