import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'glass_card.dart';

class MotivationQuoteCard extends StatelessWidget {
  const MotivationQuoteCard({super.key});

  static const _quotes = [
    ('You are stronger than yesterday.', 'Tahsin'),
    ('One honest page can heal a heavy heart.', 'Tahsin'),
    ('Small steps still count, Raisa.', 'Tahsin'),
    ('Your feelings matter — every single one.', 'Tahsin'),
  ];

  @override
  Widget build(BuildContext context) {
    final index = DateTime.now().day % _quotes.length;
    final quote = _quotes[index];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s spark',
            style: TextStyle(fontSize: 12, color: AppColors.pink.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            '"${quote.$1}"',
            style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4),
          ),
          const SizedBox(height: 6),
          Text('— ${quote.$2}', style: const TextStyle(fontSize: 12, color: AppColors.pink)),
        ],
      ),
    );
  }
}
