import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/portfolio_chart_data.dart';
import '../../domain/value_objects/dashboard_view_mode.dart';
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
  final PortfolioChartData chartData;
  final AssetFilterCategory selectedCategory;
  final TimeRange selectedTimeRange;
  final bool isBalanceVisible;
  final DashboardViewMode viewMode;
  final List<NewsArticle> news;

  const DashboardLoaded({
    required this.stats,
    required this.assets,
    required this.chartData,
    this.selectedCategory = AssetFilterCategory.trending,
    this.selectedTimeRange = TimeRange.month,
    this.isBalanceVisible = true,
    this.viewMode = DashboardViewMode.lite,
    this.news = const [],
  });

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<Asset>? assets,
    PortfolioChartData? chartData,
    AssetFilterCategory? selectedCategory,
    TimeRange? selectedTimeRange,
    bool? isBalanceVisible,
    DashboardViewMode? viewMode,
    List<NewsArticle>? news,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      assets: assets ?? this.assets,
      chartData: chartData ?? this.chartData,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
      viewMode: viewMode ?? this.viewMode,
      news: news ?? this.news,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        assets,
        chartData,
        selectedCategory,
        selectedTimeRange,
        isBalanceVisible,
        viewMode,
        news,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
