import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'candlestick.dart';

class AssetDetail extends Equatable {
  final Asset asset;
  final List<Candlestick> candles;
  final double chartMin;
  final double chartMax;
  final DateTime chartRangeStart;
  final DateTime chartRangeEnd;
  final double totalAssetValue;
  final List<DetailStatRow> detailStats;
  final String aboutText;

  const AssetDetail({
    required this.asset,
    required this.candles,
    required this.chartMin,
    required this.chartMax,
    required this.chartRangeStart,
    required this.chartRangeEnd,
    required this.totalAssetValue,
    required this.detailStats,
    required this.aboutText,
  });

  @override
  List<Object?> get props => [
        asset,
        candles,
        chartMin,
        chartMax,
        chartRangeStart,
        chartRangeEnd,
        totalAssetValue,
        detailStats,
        aboutText,
      ];
}

class DetailStatRow extends Equatable {
  final String label;
  final String value;

  const DetailStatRow({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}
