import '../../domain/entities/news_article.dart';

class NewsArticleModel extends NewsArticle {
  const NewsArticleModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    super.imageCaption,
    super.imageCaptionLine2,
    super.badgeLabel,
    required super.publishedAt,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      imageCaption: json['image_caption'] as String?,
      imageCaptionLine2: json['image_caption_line2'] as String?,
      badgeLabel: json['badge_label'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'image_caption': imageCaption,
      'image_caption_line2': imageCaptionLine2,
      'badge_label': badgeLabel,
      'published_at': publishedAt.toIso8601String(),
    };
  }
}
