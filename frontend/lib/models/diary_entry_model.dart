class DiaryEntryModel {
  DiaryEntryModel({
    required this.id,
    required this.content,
    this.title,
    this.moodSticker,
    this.primaryEmotion,
    this.replyText,
    this.replyType,
    required this.createdAt,
  });

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['id'] as String,
      content: json['content'] as String,
      title: json['title'] as String?,
      moodSticker: json['mood_sticker'] as String?,
      primaryEmotion: json['primary_emotion'] as String?,
      replyText: json['reply_text'] as String?,
      replyType: json['reply_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String content;
  final String? title;
  final String? moodSticker;
  final String? primaryEmotion;
  final String? replyText;
  final String? replyType;
  final DateTime createdAt;
}
