import 'package:equatable/equatable.dart';

enum ActivityType { buy, sell, deposit, withdraw, reward }

class Activity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime timestamp;
  final ActivityType type;
  final String? assetTicker;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.type,
    this.assetTicker,
  });

  bool get isCredit =>
      type == ActivityType.deposit ||
      type == ActivityType.reward ||
      type == ActivityType.sell;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        amount,
        timestamp,
        type,
        assetTicker,
      ];
}
