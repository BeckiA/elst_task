import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elst_dashboard/features/dashboard/data/datasources/mock_dashboard_datasource.dart';
import 'package:elst_dashboard/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:elst_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_assets.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_news.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_portfolio_chart_data.dart';
import 'package:elst_dashboard/features/dashboard/presentation/bloc/dashboard_bloc.dart';

/// Single [DashboardRepository] for dashboard and pushed routes (e.g. asset detail).
final DashboardRepository dashboardRepository = DashboardRepositoryImpl(
  dataSource: MockDashboardDataSource(),
);

/// Provides all BLoC providers for the app.
/// In a real project, use a proper DI container (get_it, injectable, etc.).
List<BlocProvider> get appBlocProviders {
  final getDashboardStats = GetDashboardStats(dashboardRepository);
  final getAssets = GetAssets(dashboardRepository);
  final getPortfolioChartData = GetPortfolioChartData(dashboardRepository);
  final getNews = GetNews(dashboardRepository);

  return [
    BlocProvider<DashboardBloc>(
      create: (_) => DashboardBloc(
        getDashboardStats: getDashboardStats,
        getAssets: getAssets,
        getPortfolioChartData: getPortfolioChartData,
        getNews: getNews,
      ),
    ),
  ];
}
