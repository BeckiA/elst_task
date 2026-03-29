import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
            icon: FontAwesomeIcons.bity,
            label: 'Crypto',
            balance: cryptoBalance,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildBalanceCard(
            icon: LucideIcons.circleDollarSign,
            label: 'Cash',
            balance: cashBalance,
            iconColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required dynamic icon,
    required String label,
    required double balance,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: icon is IconData
                  ? Icon(icon, color: iconColor, size: 24)
                  : FaIcon(icon, color: iconColor, size: 24),
            ),
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
            isVisible ? CurrencyFormatter.formatRupiah(balance) : '••••••',
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
