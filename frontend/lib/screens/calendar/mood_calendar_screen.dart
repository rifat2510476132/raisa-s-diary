import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/particle_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/mood_calendar_widget.dart';

class MoodCalendarScreen extends ConsumerStatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  ConsumerState<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends ConsumerState<MoodCalendarScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendar = ref.watch(moodCalendarProvider((year: _year, month: _month)));
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Calendar')),
      body: ParticleBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Text('${months[_month - 1]} $_year', style: Theme.of(context).textTheme.titleMedium),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 16),
            calendar.when(
              data: (days) => GlassCard(
                child: MoodCalendarWidget(year: _year, month: _month, days: days),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const GlassCard(
                child: Text('Could not load calendar. Check your connection.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
