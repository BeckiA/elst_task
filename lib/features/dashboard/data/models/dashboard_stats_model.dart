import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.portfolioValue,
    required super.totalReturn,
    required super.returnPercentage,
    required super.cryptoBalance,
    required super.cashBalance,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      portfolioValue: (json['portfolio_value'] as num).toDouble(),
      totalReturn: (json['total_return'] as num).toDouble(),
      returnPercentage: (json['return_percentage'] as num).toDouble(),
      cryptoBalance: (json['crypto_balance'] as num).toDouble(),
      cashBalance: (json['cash_balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolio_value': portfolioValue,
      'total_return': totalReturn,
      'return_percentage': returnPercentage,
      'crypto_balance': cryptoBalance,
      'cash_balance': cashBalance,
    };
  }
}
