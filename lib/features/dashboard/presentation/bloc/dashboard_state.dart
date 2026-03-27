import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/portfolio_chart_data.dart';
import '../../domain/value_objects/filter_values.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<Asset> assets;
  final List<Activity> activities;
  final PortfolioChartData chartData;
  final AssetFilterCategory selectedCategory;
  final TimeRange selectedTimeRange;
  final bool isBalanceVisible;

  const DashboardLoaded({
    required this.stats,
    required this.assets,
    required this.activities,
    required this.chartData,
    this.selectedCategory = AssetFilterCategory.trading,
    this.selectedTimeRange = TimeRange.month,
    this.isBalanceVisible = true,
  });

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<Asset>? assets,
    List<Activity>? activities,
    PortfolioChartData? chartData,
    AssetFilterCategory? selectedCategory,
    TimeRange? selectedTimeRange,
    bool? isBalanceVisible,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      assets: assets ?? this.assets,
      activities: activities ?? this.activities,
      chartData: chartData ?? this.chartData,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        assets,
        activities,
        chartData,
        selectedCategory,
        selectedTimeRange,
        isBalanceVisible,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
