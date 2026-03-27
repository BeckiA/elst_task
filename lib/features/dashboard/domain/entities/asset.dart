import 'package:equatable/equatable.dart';

class Asset extends Equatable {
  final String id;
  final String name;
  final String ticker;
  final String iconUrl;
  final double price;
  final double priceChange;
  final double changePercentage;
  final List<double> sparklineData;

  const Asset({
    required this.id,
    required this.name,
    required this.ticker,
    required this.iconUrl,
    required this.price,
    required this.priceChange,
    required this.changePercentage,
    required this.sparklineData,
  });

  bool get isPositive => changePercentage >= 0;

  @override
  List<Object?> get props => [
        id,
        name,
        ticker,
        iconUrl,
        price,
        priceChange,
        changePercentage,
        sparklineData,
      ];
}
