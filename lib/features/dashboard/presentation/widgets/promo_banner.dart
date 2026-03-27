import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback? onAction;

  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // Layer 0: The blue background completing the header
        Container(
          height: 80,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.headerGradientEnd,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),

        // Layer 1: Back translucent card
        Positioned(
          top: 16,
          left: AppSpacing.xl * 1.5,
          right: AppSpacing.xl * 1.5,
          bottom: 24, // keep it above the bottom of the main card
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.2,
              ), // looks like frosted glass against the blue
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),

        // Layer 2: Middle translucent card
        Positioned(
          top: 24,
          left: AppSpacing.lg * 1.5,
          right: AppSpacing.lg * 1.5,
          bottom: 12, // keep it above the bottom of the main card
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),

        // Layer 3: Main solid card
        Container(
          margin: const EdgeInsets.only(
            top: 32,
            left: AppSpacing.md,
            right: AppSpacing.md,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: 28, // Increased vertical padding for more height
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant, // Very pale tint
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                  backgroundColor: AppColors.primary,
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
