import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/value_objects/dashboard_view_mode.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback? onAction;
  final DashboardViewMode viewMode;

  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionText,
    this.onAction,
    required this.viewMode,
  });

  Color get _bridgeBandColor => viewMode == DashboardViewMode.lite
      ? AppColors.liteHeaderGradientBottom
      : AppColors.headerGradientEnd;

  Color get _ctaBackground => viewMode == DashboardViewMode.lite
      ? AppColors.liteHeaderGradientTop
      : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _bridgeBandColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: AppSpacing.xl * 1.5,
          right: AppSpacing.xl * 1.5,
          bottom: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          top: 24,
          left: AppSpacing.lg * 1.5,
          right: AppSpacing.lg * 1.5,
          bottom: 12,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 32,
            left: AppSpacing.md,
            right: AppSpacing.md,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: 28,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: onAction ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ctaBackground,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                child: Text(
                  actionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
