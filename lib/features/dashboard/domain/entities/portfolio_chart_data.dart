import 'package:equatable/equatable.dart';

class PortfolioChartPoint extends Equatable {
  final DateTime date;
  final double value;

  const PortfolioChartPoint({
    required this.date,
    required this.value,
  });

  @override
  List<Object?> get props => [date, value];
}

class PortfolioChartData extends Equatable {
  final List<PortfolioChartPoint> points;
  final double minValue;
  final double maxValue;

  const PortfolioChartData({
    required this.points,
    required this.minValue,
    required this.maxValue,
  });

  @override
  List<Object?> get props => [points, minValue, maxValue];
}
