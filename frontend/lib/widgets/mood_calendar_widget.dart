import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/emotion_utils.dart';
import '../models/mood_calendar_day.dart';

class MoodCalendarWidget extends StatelessWidget {
  const MoodCalendarWidget({
    super.key,
    required this.year,
    required this.month,
    required this.days,
    this.onDayTap,
  });

  final int year;
  final int month;
  final List<MoodCalendarDay> days;
  final void Function(DateTime date)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = first.weekday % 7;
    final byDate = {
      for (final d in days)
        DateTime(d.date.year, d.date.month, d.date.day): d,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(d, style: const TextStyle(fontSize: 11)),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) return const SizedBox.shrink();
            final day = index - startWeekday + 1;
            final date = DateTime(year, month, day);
            final mood = byDate[date];
            final hasEntry = mood?.hasEntry ?? false;

            return GestureDetector(
              onTap: () => onDayTap?.call(date),
              child: Container(
                decoration: BoxDecoration(
                  color: hasEntry
                      ? AppColors.pink.withValues(alpha: 0.2)
                      : Theme.of(context).cardColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: hasEntry
                      ? Border.all(color: AppColors.pink.withValues(alpha: 0.5))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$day', style: const TextStyle(fontSize: 11)),
                    if (hasEntry)
                      Text(
                        mood?.moodSticker ?? EmotionUtils.emojiFor(mood?.primaryEmotion),
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
