import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final double portfolioValue;
  final double totalReturn;
  final double returnPercentage;
  final double cryptoBalance;
  final double cashBalance;

  const DashboardStats({
    required this.portfolioValue,
    required this.totalReturn,
    required this.returnPercentage,
    required this.cryptoBalance,
    required this.cashBalance,
  });

  @override
  List<Object?> get props => [
        portfolioValue,
        totalReturn,
        returnPercentage,
        cryptoBalance,
        cashBalance,
      ];
}
