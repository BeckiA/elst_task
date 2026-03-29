import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

/// Horizontal spot-price strip for Pro dashboard (matches product reference).
class CryptoSpotPriceCards extends StatelessWidget {
  const CryptoSpotPriceCards({super.key});

  static const List<_SpotRow> _rows = [
    _SpotRow(symbol: 'BTC', priceIdr: 1977644908, changePercent: 4.2),
    _SpotRow(symbol: 'ETH', priceIdr: 73606618, changePercent: -3.1),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        physics: const BouncingScrollPhysics(),
        itemCount: _rows.length,
        separatorBuilder: (context, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final row = _rows[index];
          return _SpotCard(row: row);
        },
      ),
    );
  }
}

class _SpotRow {
  const _SpotRow({
    required this.symbol,
    required this.priceIdr,
    required this.changePercent,
  });

  final String symbol;
  final double priceIdr;
  final double changePercent;
}

class _SpotCard extends StatelessWidget {
  const _SpotCard({required this.row});

  final _SpotRow row;

  @override
  Widget build(BuildContext context) {
    final isUp = row.changePercent >= 0;
    final changeText = isUp
        ? CurrencyFormatter.formatPercentage(row.changePercent)
        : '${row.changePercent.abs().toStringAsFixed(1)}%';

    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            row.symbol,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.formatRupiah(row.priceIdr),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            changeText,
            style: TextStyle(
              color: isUp ? AppColors.positive : AppColors.negative,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
