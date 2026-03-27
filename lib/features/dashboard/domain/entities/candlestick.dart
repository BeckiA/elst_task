import 'package:equatable/equatable.dart';

class Candlestick extends Equatable {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  const Candlestick({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  bool get isUp => close >= open;

  @override
  List<Object?> get props => [time, open, high, low, close];
}
