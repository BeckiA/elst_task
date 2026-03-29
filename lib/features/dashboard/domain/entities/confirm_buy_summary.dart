import 'package:equatable/equatable.dart';

import 'asset.dart';

/// Snapshot of a pending buy for the confirm screen (DDD entity).
class ConfirmBuySummary extends Equatable {
  const ConfirmBuySummary({
    required this.ticker,
    required this.cryptoAmount,
    required this.buyPricePerUnitIdr,
    required this.amountIdr,
    required this.transactionFeeIdr,
    required this.taxIdr,
    required this.totalToPayIdr,
  });

  final String ticker;
  final double cryptoAmount;
  final double buyPricePerUnitIdr;
  final int amountIdr;
  final double transactionFeeIdr;
  final double taxIdr;
  final double totalToPayIdr;

  factory ConfirmBuySummary.fromInputs({
    required Asset asset,
    required double spotPrice,
    required int amountIdr,
  }) {
    const fee = 0.0;
    const tax = 0.0;
    final crypto = spotPrice > 0 ? amountIdr / spotPrice : 0.0;
    return ConfirmBuySummary(
      ticker: asset.ticker,
      cryptoAmount: crypto,
      buyPricePerUnitIdr: spotPrice,
      amountIdr: amountIdr,
      transactionFeeIdr: fee,
      taxIdr: tax,
      totalToPayIdr: amountIdr + fee + tax,
    );
  }

  @override
  List<Object?> get props => [
        ticker,
        cryptoAmount,
        buyPricePerUnitIdr,
        amountIdr,
        transactionFeeIdr,
        taxIdr,
        totalToPayIdr,
      ];
}
