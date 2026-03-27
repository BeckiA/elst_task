import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class BalanceSummaryCards extends StatelessWidget {
  final double cryptoBalance;
  final double cashBalance;
  final bool isVisible;

  const BalanceSummaryCards({
    super.key,
    required this.cryptoBalance,
    required this.cashBalance,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          _buildBalanceCard(
            icon: Icons.currency_bitcoin_rounded,
            label: 'Crypto',
            balance: cryptoBalance,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildBalanceCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Cash',
            balance: cashBalance,
            iconColor: AppColors.positive,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required IconData icon,
    required String label,
    required double balance,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            isVisible
                ? CurrencyFormatter.formatRupiah(balance)
                : '••••••',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
