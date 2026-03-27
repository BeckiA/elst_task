import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/activity.dart';

class ActivityListSection extends StatelessWidget {
  final List<Activity> activities;

  const ActivityListSection({super.key, required this.activities});

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
                'Recent Activity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...activities.map((activity) => _ActivityTile(activity: activity)),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.description} · ${DateFormatter.timeAgo(activity.timestamp)}',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${activity.isCredit ? '+' : '-'}${CurrencyFormatter.formatRupiah(activity.amount)}',
            style: TextStyle(
              color: activity.isCredit ? AppColors.positive : AppColors.negative,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (activity.type) {
      case ActivityType.buy:
        icon = Icons.arrow_downward_rounded;
        color = AppColors.primary;
        break;
      case ActivityType.sell:
        icon = Icons.arrow_upward_rounded;
        color = AppColors.positive;
        break;
      case ActivityType.deposit:
        icon = Icons.account_balance_rounded;
        color = AppColors.primary;
        break;
      case ActivityType.withdraw:
        icon = Icons.send_rounded;
        color = AppColors.negative;
        break;
      case ActivityType.reward:
        icon = Icons.card_giftcard_rounded;
        color = AppColors.warning;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
