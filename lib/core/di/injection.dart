import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elst_dashboard/features/dashboard/data/datasources/mock_dashboard_datasource.dart';
import 'package:elst_dashboard/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_assets.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_recent_activities.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_portfolio_chart_data.dart';
import 'package:elst_dashboard/features/dashboard/presentation/bloc/dashboard_bloc.dart';

/// Provides all BLoC providers for the app.
/// In a real project, use a proper DI container (get_it, injectable, etc.).
List<BlocProvider> get appBlocProviders {
  // Data sources
  final mockDataSource = MockDashboardDataSource();

  // Repositories
  final dashboardRepository = DashboardRepositoryImpl(
    dataSource: mockDataSource,
  );

  // Use cases
  final getDashboardStats = GetDashboardStats(dashboardRepository);
  final getAssets = GetAssets(dashboardRepository);
  final getRecentActivities = GetRecentActivities(dashboardRepository);
  final getPortfolioChartData = GetPortfolioChartData(dashboardRepository);

  return [
    BlocProvider<DashboardBloc>(
      create: (_) => DashboardBloc(
        getDashboardStats: getDashboardStats,
        getAssets: getAssets,
        getRecentActivities: getRecentActivities,
        getPortfolioChartData: getPortfolioChartData,
      ),
    ),
  ];
}
