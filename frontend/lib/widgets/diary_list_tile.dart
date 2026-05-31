import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/emotion_utils.dart';
import '../models/diary_entry_model.dart';
import 'glass_card.dart';

class DiaryListTile extends StatelessWidget {
  const DiaryListTile({super.key, required this.entry, this.onTap});
  final DiaryEntryModel entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(EmotionUtils.emojiFor(entry.primaryEmotion), style: const TextStyle(fontSize: 20)),
              if (entry.moodSticker != null) ...[
                const SizedBox(width: 6),
                Text(entry.moodSticker!, style: const TextStyle(fontSize: 18)),
              ],
              const SizedBox(width: 8),
              if (entry.primaryEmotion != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pink.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    EmotionUtils.labelFor(entry.primaryEmotion),
                    style: const TextStyle(fontSize: 11, color: AppColors.pink),
                  ),
                ),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(entry.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (entry.title != null && entry.title!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(entry.title!, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 8),
          Text(entry.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(height: 1.4)),
          if (entry.replyText != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Tahsin: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.pink)),
                Expanded(
                  child: Text(
                    entry.replyText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: AppColors.pink.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
