import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/news_article.dart';

class DashboardNewsSection extends StatelessWidget {
  final List<NewsArticle> articles;

  const DashboardNewsSection({super.key, required this.articles});

  static const double _cardWidth = 280;

  /// ~16:9 at card width — taller image for stacked caption pills + badge.
  static const double _imageHeight = 180;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'News',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 268,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: articles.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              return _NewsCard(
                article: articles[index],
                cardWidth: _cardWidth,
                imageHeight: _imageHeight,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  final double cardWidth;
  final double imageHeight;

  const _NewsCard({
    required this.article,
    required this.cardWidth,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 3,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: SizedBox(
                  width: cardWidth,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _NewsCoverImage(
                        article: article,
                        width: cardWidth,
                        height: imageHeight,
                      ),
                      if ((article.badgeLabel ?? '').isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.graduationCap,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                article.badgeLabel!.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_hasCaptionOverlay(article))
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if ((article.imageCaption ?? '').isNotEmpty) ...[
                                _TealCaptionPill(
                                  text: article.imageCaption!,
                                  maxWidth: cardWidth - 24,
                                ),
                                if ((article.imageCaptionLine2 ?? '')
                                    .isNotEmpty)
                                  const SizedBox(height: 6),
                              ],
                              if ((article.imageCaptionLine2 ?? '').isNotEmpty)
                                _TealCaptionPill(
                                  text: article.imageCaptionLine2!,
                                  maxWidth: cardWidth - 24,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              DateFormatter.formatShortDate(article.publishedAt),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasCaptionOverlay(NewsArticle a) {
    return (a.imageCaption ?? '').isNotEmpty ||
        (a.imageCaptionLine2 ?? '').isNotEmpty;
  }
}

class _TealCaptionPill extends StatelessWidget {
  final String text;
  final double maxWidth;

  const _TealCaptionPill({required this.text, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.liteHeaderGradientBottom,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsCoverImage extends StatelessWidget {
  final NewsArticle article;
  final double width;
  final double height;

  const _NewsCoverImage({
    required this.article,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (article.isAssetImage) {
      return Image.asset(
        article.imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return Image.network(
      article.imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.filterChipSelected.withValues(alpha: 0.25),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.filterChipSelected,
        size: 40,
      ),
    );
  }
}
