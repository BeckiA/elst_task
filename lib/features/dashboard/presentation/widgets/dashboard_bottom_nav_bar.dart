import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/value_objects/dashboard_view_mode.dart';

class DashboardBottomNavBar extends StatelessWidget {
  final DashboardViewMode viewMode;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DashboardBottomNavBar({
    super.key,
    required this.viewMode,
    required this.currentIndex,
    required this.onTap,
  });

  bool get _isPro => viewMode == DashboardViewMode.pro;

  @override
  Widget build(BuildContext context) {
    return _buildLiteFloatingPill();
  }

  /// Frosted glass floating capsule (Lite and Pro).
  Widget _buildLiteFloatingPill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavIcon(
                icon: LucideIcons.home,
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavIcon(
                icon: LucideIcons.chartNoAxesColumn,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              if (_isPro) ...[
                _NavIcon(
                  icon: LucideIcons.arrowLeftRight,
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavIcon(
                  icon: LucideIcons.wallet,
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ] else
                _NavIcon(
                  icon: LucideIcons.wallet,
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textTertiary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
