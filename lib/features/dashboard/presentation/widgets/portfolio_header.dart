import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/portfolio_chart_data.dart';
import '../../domain/value_objects/dashboard_view_mode.dart';

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var max = size.width;
    var dashWidth = 4.0;
    var dashSpace = 4.0;
    double startX = 0;

    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HeaderXWatermark extends StatelessWidget {
  final double size;

  const _HeaderXWatermark({required this.size});

  @override
  Widget build(BuildContext context) {
    final barLength = size * 1.05;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (final angle in [math.pi / 4, -math.pi / 4])
            Transform.rotate(
              angle: angle,
              child: Container(
                width: 42,
                height: barLength,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PortfolioHeader extends StatelessWidget {
  final DashboardStats stats;
  final PortfolioChartData chartData;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final DashboardViewMode viewMode;
  final ValueChanged<DashboardViewMode> onViewModeChanged;
  final VoidCallback? onTopUp;
  final Widget child;

  const PortfolioHeader({
    super.key,
    required this.stats,
    required this.chartData,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    required this.viewMode,
    required this.onViewModeChanged,
    this.onTopUp,
    required this.child,
  });

  bool get _isLite => viewMode == DashboardViewMode.lite;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isLite
              ? const [
                  AppColors.liteHeaderGradientTop,
                  AppColors.liteHeaderGradientTop,
                  AppColors.liteHeaderGradientBottom,
                ]
              : const [
                  AppColors.headerGradientStart,
                  AppColors.headerGradientMid,
                  AppColors.headerGradientEnd,
                ],
          stops: _isLite ? const [0.0, 0.28, 1.0] : null,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_isLite)
            Positioned(
              right: -56,
              bottom: -40,
              child: Opacity(
                opacity: 0.1,
                child: _HeaderXWatermark(size: 280),
              ),
            )
          else
            Positioned(
              right: -80,
              bottom: -80,
              child: Opacity(
                opacity: 0.05,
                child: _HeaderXWatermark(size: 320),
              ),
            ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: AppSpacing.md),
                if (_isLite) ...[
                  _buildLitePortfolioSection(context),
                  const SizedBox(height: AppSpacing.sm),
                  _buildReturnInfoLite(context),
                  const SizedBox(height: AppSpacing.xl),
                  child,
                ] else ...[
                  _buildPortfolioValue(context),
                  const SizedBox(height: AppSpacing.sm),
                  _buildReturnInfoPro(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLargeChart(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                    ),
                    child: CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: DottedLinePainter(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modeSegment(
                  label: 'Lite',
                  isSelected: _isLite,
                  isLiteSlot: true,
                  onTap: () => onViewModeChanged(DashboardViewMode.lite),
                ),
                _modeSegment(
                  label: 'Pro',
                  isSelected: !_isLite,
                  isLiteSlot: false,
                  onTap: () => onViewModeChanged(DashboardViewMode.pro),
                ),
              ],
            ),
          ),
          const Spacer(),
          _headerIcon(LucideIcons.search),
          const SizedBox(width: AppSpacing.md),
          _headerIcon(LucideIcons.bell),
          const SizedBox(width: AppSpacing.md),
          _headerIcon(LucideIcons.circleUser),
        ],
      ),
    );
  }

  Widget _modeSegment({
    required String label,
    required bool isSelected,
    required bool isLiteSlot,
    required VoidCallback onTap,
  }) {
    late final Widget inner;
    if (isSelected && isLiteSlot) {
      inner = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.liteHeaderGradientTop,
              AppColors.liteHeaderGradientBottom,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (isSelected && !isLiteSlot) {
      inner = Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.headerGradientStart,
              AppColors.headerGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      inner = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: inner,
    );
  }

  Widget _headerIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 26);
  }

  Widget _buildTopUpButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTopUp ?? () {},
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              child: const Text(
                'Top Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLitePortfolioSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio value',
                  style: TextStyle(
                    color: AppColors.headerText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isBalanceVisible
                            ? CurrencyFormatter.formatRupiah(
                                stats.portfolioValue,
                              )
                            : '••••••••',
                        style: const TextStyle(
                          color: AppColors.headerText,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: onToggleVisibility,
                      child: Icon(
                        isBalanceVisible
                            ? LucideIcons.eye
                            : LucideIcons.eyeOff,
                        color: AppColors.headerText,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _buildTopUpButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioValue(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio value',
            style: TextStyle(
              color: AppColors.headerText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                isBalanceVisible
                    ? CurrencyFormatter.formatRupiah(stats.portfolioValue)
                    : '••••••••',
                style: const TextStyle(
                  color: AppColors.headerText,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isBalanceVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: AppColors.headerTextSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnInfoLite(BuildContext context) {
    final text = isBalanceVisible
        ? 'Total return ${CurrencyFormatter.formatChange(stats.totalReturn)} (${CurrencyFormatter.formatPercentage(stats.returnPercentage)})'
        : 'Total return ••••';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.positive,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReturnInfoPro(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Text(
            'Total return ',
            style: TextStyle(
              color: AppColors.headerText,
              fontSize: 12,
            ),
          ),
          Text(
            isBalanceVisible
                ? '${CurrencyFormatter.formatChange(stats.totalReturn)} (${CurrencyFormatter.formatPercentage(stats.returnPercentage)})'
                : '••••',
            style: const TextStyle(
              color: AppColors.positive,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeChart() {
    if (chartData.points.isEmpty) return const SizedBox(height: 140);

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          clipData: const FlClipData.all(),
          minY: chartData.minValue * 0.92,
          maxY: chartData.maxValue * 1.05,
          lineBarsData: [
            LineChartBarData(
              spots: chartData.points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                  .toList(),
              isCurved: false,
              color: const Color(
                0xFF00D2FF,
              ).withValues(alpha: 0.5),
              barWidth: 2.0,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00D2FF).withValues(alpha: 0.15),
                    const Color(0xFF00D2FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}
