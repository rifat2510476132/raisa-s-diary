import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/utils/emotion_utils.dart';

class EmotionBarChart extends StatelessWidget {
  const EmotionBarChart({super.key, required this.summary});
  final List<dynamic> summary;

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) {
      return const Center(child: Text('No emotion data yet'));
    }

    final bars = summary.asMap().entries.map((e) {
      final item = e.value as Map<String, dynamic>;
      final emotion = item['primary_emotion'] as String? ?? 'unknown';
      final count = (int.tryParse(item['count'].toString()) ?? 1).toDouble();
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: count,
            color: EmotionUtils.colorFor(emotion, e.key),
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: bars,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= summary.length) return const SizedBox.shrink();
                final item = summary[value.toInt()] as Map<String, dynamic>;
                final emotion = item['primary_emotion'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    EmotionUtils.emojiFor(emotion),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }
}
