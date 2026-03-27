import 'package:equatable/equatable.dart';

import '../../domain/entities/asset.dart';
import '../../domain/value_objects/asset_market_tab.dart';
import '../../domain/value_objects/chart_display_mode.dart';
import '../../domain/value_objects/chart_timeframe.dart';

abstract class AssetDetailEvent extends Equatable {
  const AssetDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssetDetail extends AssetDetailEvent {
  final Asset asset;

  const LoadAssetDetail(this.asset);

  @override
  List<Object?> get props => [asset];
}

class ChangeAssetDetailTimeframe extends AssetDetailEvent {
  final ChartTimeframe timeframe;

  const ChangeAssetDetailTimeframe(this.timeframe);

  @override
  List<Object?> get props => [timeframe];
}

class SelectAssetMarketTab extends AssetDetailEvent {
  final AssetMarketTab tab;

  const SelectAssetMarketTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

class SetAssetChartDisplayMode extends AssetDetailEvent {
  final ChartDisplayMode mode;

  const SetAssetChartDisplayMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ToggleAssetDetailSection extends AssetDetailEvent {
  final String sectionId;

  const ToggleAssetDetailSection(this.sectionId);

  @override
  List<Object?> get props => [sectionId];
}

class ToggleAssetFavorite extends AssetDetailEvent {
  const ToggleAssetFavorite();
}
