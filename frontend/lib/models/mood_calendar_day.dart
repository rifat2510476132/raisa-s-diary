class MoodCalendarDay {
  MoodCalendarDay({
    required this.date,
    this.primaryEmotion,
    this.moodSticker,
    this.entryCount = 0,
  });

  factory MoodCalendarDay.fromJson(Map<String, dynamic> json) {
    return MoodCalendarDay(
      date: DateTime.parse(json['date'] as String),
      primaryEmotion: json['primary_emotion'] as String?,
      moodSticker: json['mood_sticker'] as String?,
      entryCount: json['entry_count'] as int? ?? 0,
    );
  }

  final DateTime date;
  final String? primaryEmotion;
  final String? moodSticker;
  final int entryCount;

  bool get hasEntry => entryCount > 0;
}
