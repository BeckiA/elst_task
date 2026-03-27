import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/asset.dart';

class AssetListTile extends StatelessWidget {
  final Asset asset;
  final int index;
  final VoidCallback? onTap;

  const AssetListTile({
    super.key,
    required this.asset,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _buildAssetIcon(),
            const SizedBox(width: AppSpacing.md),
            _buildAssetInfo(),
            const SizedBox(width: AppSpacing.md),
            _buildSparkline(),
            const SizedBox(width: AppSpacing.md),
            _buildPriceInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getAssetColor().withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          asset.ticker.substring(0, asset.ticker.length.clamp(0, 2)),
          style: TextStyle(
            color: _getAssetColor(),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _getAssetColor() {
    final colors = [
      const Color(0xFFF7931A), // Bitcoin gold
      const Color(0xFF627EEA), // Ethereum blue
      const Color(0xFF14F195), // Solana green
      const Color(0xFF0033AD), // Cardano blue
      const Color(0xFF8247E5), // Polygon purple
      const Color(0xFF00AAE4), // Ripple blue
      const Color(0xFFC2A633), // Doge gold
      const Color(0xFFE84142), // Avalanche red
    ];
    return colors[index % colors.length];
  }

  Widget _buildAssetInfo() {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            asset.name,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            asset.ticker,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkline() {
    final color = asset.isPositive ? AppColors.positive : AppColors.negative;
    return SizedBox(
      width: 60,
      height: 32,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: asset.sparklineData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              curveSmoothness: 0.35,
              color: color,
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Expanded(
      flex: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            CurrencyFormatter.formatRupiah(asset.price),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${CurrencyFormatter.formatChange(asset.priceChange)} (${CurrencyFormatter.formatPercentage(asset.changePercentage)})',
            style: TextStyle(
              color: asset.isPositive ? AppColors.positive : AppColors.negative,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
