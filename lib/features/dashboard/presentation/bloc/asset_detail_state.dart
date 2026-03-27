import 'package:equatable/equatable.dart';

import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_detail.dart';
import '../../domain/value_objects/asset_market_tab.dart';
import '../../domain/value_objects/chart_display_mode.dart';
import '../../domain/value_objects/chart_timeframe.dart';

abstract class AssetDetailState extends Equatable {
  const AssetDetailState();

  @override
  List<Object?> get props => [];
}

class AssetDetailInitial extends AssetDetailState {
  const AssetDetailInitial();
}

class AssetDetailLoading extends AssetDetailState {
  final Asset asset;
  final ChartTimeframe timeframe;

  const AssetDetailLoading({
    required this.asset,
    required this.timeframe,
  });

  @override
  List<Object?> get props => [asset, timeframe];
}

class AssetDetailLoaded extends AssetDetailState {
  final AssetDetail detail;
  final ChartTimeframe timeframe;
  final AssetMarketTab selectedTab;
  final ChartDisplayMode chartMode;
  final bool totalAssetExpanded;
  final bool detailStatsExpanded;
  final bool aboutExpanded;
  final bool isFavorite;

  const AssetDetailLoaded({
    required this.detail,
    required this.timeframe,
    this.selectedTab = AssetMarketTab.market,
    this.chartMode = ChartDisplayMode.candlestick,
    this.totalAssetExpanded = true,
    this.detailStatsExpanded = true,
    this.aboutExpanded = true,
    this.isFavorite = false,
  });

  AssetDetailLoaded copyWith({
    AssetDetail? detail,
    ChartTimeframe? timeframe,
    AssetMarketTab? selectedTab,
    ChartDisplayMode? chartMode,
    bool? totalAssetExpanded,
    bool? detailStatsExpanded,
    bool? aboutExpanded,
    bool? isFavorite,
  }) {
    return AssetDetailLoaded(
      detail: detail ?? this.detail,
      timeframe: timeframe ?? this.timeframe,
      selectedTab: selectedTab ?? this.selectedTab,
      chartMode: chartMode ?? this.chartMode,
      totalAssetExpanded: totalAssetExpanded ?? this.totalAssetExpanded,
      detailStatsExpanded: detailStatsExpanded ?? this.detailStatsExpanded,
      aboutExpanded: aboutExpanded ?? this.aboutExpanded,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        detail,
        timeframe,
        selectedTab,
        chartMode,
        totalAssetExpanded,
        detailStatsExpanded,
        aboutExpanded,
        isFavorite,
      ];
}

class AssetDetailError extends AssetDetailState {
  final Asset asset;
  final String message;

  const AssetDetailError({required this.asset, required this.message});

  @override
  List<Object?> get props => [asset, message];
}
