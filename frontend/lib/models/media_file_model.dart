class MediaFileModel {
  MediaFileModel({
    required this.id,
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.createdAt,
  });

  factory MediaFileModel.fromJson(Map<String, dynamic> json) {
    return MediaFileModel(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] as String? ?? 'image',
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String url;
  final String type;
  final String? thumbnailUrl;
  final DateTime? createdAt;
}
