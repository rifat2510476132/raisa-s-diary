import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class RelationshipBadge extends StatelessWidget {
  const RelationshipBadge({super.key, required this.level});
  final int level;

  String get _label {
    if (level >= 10) return 'Soulmates 💕';
    if (level >= 7) return 'Deep bond';
    if (level >= 4) return 'Growing closer';
    return 'Getting to know you';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pink.withValues(alpha: 0.2),
            AppColors.rose.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pink.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, size: 16, color: AppColors.pink),
          const SizedBox(width: 6),
          Text('Lv.$level · $_label', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
