import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/asset.dart';
import '../../domain/usecases/get_asset_detail.dart';
import '../../domain/value_objects/chart_timeframe.dart';
import 'asset_detail_event.dart';
import 'asset_detail_state.dart';

class AssetDetailBloc extends Bloc<AssetDetailEvent, AssetDetailState> {
  final GetAssetDetail getAssetDetail;

  AssetDetailBloc({required this.getAssetDetail})
      : super(const AssetDetailInitial()) {
    on<LoadAssetDetail>(_onLoad);
    on<ChangeAssetDetailTimeframe>(_onTimeframe);
    on<SelectAssetMarketTab>(_onSelectTab);
    on<SetAssetChartDisplayMode>(_onChartMode);
    on<ToggleAssetDetailSection>(_onToggleSection);
    on<ToggleAssetFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoad(
    LoadAssetDetail event,
    Emitter<AssetDetailState> emit,
  ) async {
    const tf = ChartTimeframe.oneWeek;
    emit(AssetDetailLoading(asset: event.asset, timeframe: tf));
    try {
      final detail = await getAssetDetail(event.asset.id, timeframe: tf);
      emit(
        AssetDetailLoaded(
          detail: detail,
          timeframe: tf,
        ),
      );
    } catch (e) {
      emit(
        AssetDetailError(
          asset: event.asset,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onTimeframe(
    ChangeAssetDetailTimeframe event,
    Emitter<AssetDetailState> emit,
  ) async {
    final current = state;
    late final Asset asset;
    AssetDetailLoaded? previous;

    if (current is AssetDetailLoaded) {
      asset = current.detail.asset;
      previous = current;
    } else if (current is AssetDetailLoading) {
      asset = current.asset;
    } else if (current is AssetDetailError) {
      asset = current.asset;
    } else {
      return;
    }

    emit(AssetDetailLoading(asset: asset, timeframe: event.timeframe));
    try {
      final detail = await getAssetDetail(asset.id, timeframe: event.timeframe);
      if (previous != null) {
        emit(
          previous.copyWith(
            detail: detail,
            timeframe: event.timeframe,
          ),
        );
      } else {
        emit(
          AssetDetailLoaded(
            detail: detail,
            timeframe: event.timeframe,
          ),
        );
      }
    } catch (e) {
      emit(AssetDetailError(asset: asset, message: e.toString()));
    }
  }

  void _onSelectTab(
    SelectAssetMarketTab event,
    Emitter<AssetDetailState> emit,
  ) {
    final current = state;
    if (current is AssetDetailLoaded) {
      emit(current.copyWith(selectedTab: event.tab));
    }
  }

  void _onChartMode(
    SetAssetChartDisplayMode event,
    Emitter<AssetDetailState> emit,
  ) {
    final current = state;
    if (current is AssetDetailLoaded) {
      emit(current.copyWith(chartMode: event.mode));
    }
  }

  void _onToggleSection(
    ToggleAssetDetailSection event,
    Emitter<AssetDetailState> emit,
  ) {
    final current = state;
    if (current is! AssetDetailLoaded) return;

    switch (event.sectionId) {
      case 'total':
        emit(
          current.copyWith(
            totalAssetExpanded: !current.totalAssetExpanded,
          ),
        );
        break;
      case 'stats':
        emit(
          current.copyWith(
            detailStatsExpanded: !current.detailStatsExpanded,
          ),
        );
        break;
      case 'about':
        emit(
          current.copyWith(
            aboutExpanded: !current.aboutExpanded,
          ),
        );
        break;
    }
  }

  void _onToggleFavorite(
    ToggleAssetFavorite event,
    Emitter<AssetDetailState> emit,
  ) {
    final current = state;
    if (current is AssetDetailLoaded) {
      emit(current.copyWith(isFavorite: !current.isFavorite));
    }
  }
}
