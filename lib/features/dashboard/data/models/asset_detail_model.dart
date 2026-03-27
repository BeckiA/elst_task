import '../../domain/entities/asset_detail.dart';

class AssetDetailModel extends AssetDetail {
  const AssetDetailModel({
    required super.asset,
    required super.candles,
    required super.chartMin,
    required super.chartMax,
    required super.chartRangeStart,
    required super.chartRangeEnd,
    required super.totalAssetValue,
    required super.detailStats,
    required super.aboutText,
  });
}
