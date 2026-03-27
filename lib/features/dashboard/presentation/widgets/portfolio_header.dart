import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/portfolio_chart_data.dart';

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
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

class PortfolioHeader extends StatelessWidget {
  final DashboardStats stats;
  final PortfolioChartData chartData;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final Widget child; // For quick actions grid

  const PortfolioHeader({
    super.key,
    required this.stats,
    required this.chartData,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMid,
            AppColors.headerGradientEnd,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle background graphic opacity overlay
          Positioned(
            right: -80,
            bottom: -80,
            child: Opacity(
              opacity: 0.05,
              child: SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var angle in [math.pi / 4, -math.pi / 4])
                      Transform.rotate(
                        angle: angle,
                        child: Container(
                          width: 42,
                          height: 320,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(21),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: AppSpacing.md),
                _buildPortfolioValue(context),
                const SizedBox(height: AppSpacing.sm),
                _buildReturnInfo(context),
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
                child, // QuickActionsGrid
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
          // Lite / Pro toggle matching design exactly
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Text(
                    'Lite',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
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
                  child: const Text(
                    'Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _headerIcon(Icons.search_rounded),
          const SizedBox(width: AppSpacing.md),
          _headerIcon(Icons.notifications_none_rounded),
          const SizedBox(width: AppSpacing.md),
          _headerIcon(Icons.account_circle_outlined),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 26);
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
              color: AppColors.headerTextSecondary,
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
                style: TextStyle(
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
                  isBalanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
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

  Widget _buildReturnInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Text(
            'Total return ',
            style: TextStyle(
              color: AppColors.headerTextSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            isBalanceVisible
                ? '${CurrencyFormatter.formatChange(stats.totalReturn)} (${CurrencyFormatter.formatPercentage(stats.returnPercentage)})'
                : '••••',
            style: TextStyle(
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
              isCurved: false, // Sharp angles matching snippet 2
              color: const Color(
                0xFF00D2FF,
              ).withValues(alpha: 0.5), // Bright cyan matching snippet
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
