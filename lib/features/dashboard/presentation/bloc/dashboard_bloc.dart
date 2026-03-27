import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_assets.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_news.dart';
import '../../domain/usecases/get_portfolio_chart_data.dart';
import '../../domain/value_objects/dashboard_view_mode.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats getDashboardStats;
  final GetAssets getAssets;
  final GetPortfolioChartData getPortfolioChartData;
  final GetNews getNews;

  DashboardBloc({
    required this.getDashboardStats,
    required this.getAssets,
    required this.getPortfolioChartData,
    required this.getNews,
  }) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<FilterAssets>(_onFilterAssets);
    on<ChangeTimeRange>(_onChangeTimeRange);
    on<ToggleBalanceVisibility>(_onToggleBalanceVisibility);
    on<SetDashboardViewMode>(_onSetDashboardViewMode);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final results = await Future.wait([
        getDashboardStats(),
        getAssets(),
        getPortfolioChartData(),
        getNews(),
      ]);

      emit(DashboardLoaded(
        stats: results[0] as dynamic,
        assets: results[1] as dynamic,
        chartData: results[2] as dynamic,
        news: results[3] as dynamic,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final results = await Future.wait([
        getDashboardStats(),
        getAssets(),
        getPortfolioChartData(),
        getNews(),
      ]);

      final currentState = state;
      emit(DashboardLoaded(
        stats: results[0] as dynamic,
        assets: results[1] as dynamic,
        chartData: results[2] as dynamic,
        news: results[3] as dynamic,
        isBalanceVisible: currentState is DashboardLoaded
            ? currentState.isBalanceVisible
            : true,
        viewMode: currentState is DashboardLoaded
            ? currentState.viewMode
            : DashboardViewMode.lite,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onFilterAssets(
    FilterAssets event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      try {
        final assets = await getAssets(category: event.category);
        emit(currentState.copyWith(
          assets: assets,
          selectedCategory: event.category,
        ));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    }
  }

  Future<void> _onChangeTimeRange(
    ChangeTimeRange event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      try {
        final chartData = await getPortfolioChartData(range: event.range);
        emit(currentState.copyWith(
          chartData: chartData,
          selectedTimeRange: event.range,
        ));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    }
  }

  void _onToggleBalanceVisibility(
    ToggleBalanceVisibility event,
    Emitter<DashboardState> emit,
  ) {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(
        isBalanceVisible: !currentState.isBalanceVisible,
      ));
    }
  }

  void _onSetDashboardViewMode(
    SetDashboardViewMode event,
    Emitter<DashboardState> emit,
  ) {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(viewMode: event.mode));
    }
  }
}
