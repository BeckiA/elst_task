import 'package:equatable/equatable.dart';

class NewsArticle extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String? imageCaption;
  /// Second line on the image (stacked teal pill under [imageCaption]).
  final String? imageCaptionLine2;
  /// When set, shows centered badge (e.g. graduation cap + label) at top of image.
  final String? badgeLabel;
  final DateTime publishedAt;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.imageCaption,
    this.imageCaptionLine2,
    this.badgeLabel,
    required this.publishedAt,
  });

  bool get isAssetImage => imageUrl.startsWith('assets/');

  @override
  List<Object?> get props => [
        id,
        title,
        imageUrl,
        imageCaption,
        imageCaptionLine2,
        badgeLabel,
        publishedAt,
      ];
}
