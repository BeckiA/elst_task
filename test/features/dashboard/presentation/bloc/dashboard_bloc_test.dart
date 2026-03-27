import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:elst_dashboard/features/dashboard/data/datasources/mock_dashboard_datasource.dart';
import 'package:elst_dashboard/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:elst_dashboard/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:elst_dashboard/features/dashboard/domain/entities/portfolio_chart_data.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_assets.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_recent_activities.dart';
import 'package:elst_dashboard/features/dashboard/domain/usecases/get_portfolio_chart_data.dart';
import 'package:elst_dashboard/features/dashboard/domain/value_objects/filter_values.dart';
import 'package:elst_dashboard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:elst_dashboard/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:elst_dashboard/features/dashboard/presentation/bloc/dashboard_state.dart';

void main() {
  late DashboardBloc bloc;
  late MockDashboardDataSource dataSource;
  late DashboardRepositoryImpl repository;

  setUp(() {
    dataSource = MockDashboardDataSource();
    repository = DashboardRepositoryImpl(dataSource: dataSource);
    bloc = DashboardBloc(
      getDashboardStats: GetDashboardStats(repository),
      getAssets: GetAssets(repository),
      getRecentActivities: GetRecentActivities(repository),
      getPortfolioChartData: GetPortfolioChartData(repository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('DashboardBloc', () {
    test('initial state is DashboardInitial', () {
      expect(bloc.state, const DashboardInitial());
    });

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardLoaded] when LoadDashboard is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadDashboard()),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardLoaded>()
            .having((s) => s.stats.portfolioValue, 'portfolioValue', 8040215)
            .having((s) => s.assets.length, 'assets count', greaterThan(0))
            .having(
                (s) => s.activities.length, 'activities count', greaterThan(0))
            .having((s) => s.chartData.points.length, 'chart points',
                greaterThan(0)),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits updated state when FilterAssets is added after load',
      build: () => bloc,
      seed: () => DashboardLoaded(
        stats: const DashboardStatsStub(),
        assets: const [],
        activities: const [],
        chartData: const PortfolioChartDataStub(),
      ),
      act: (bloc) => bloc.add(const FilterAssets(AssetFilterCategory.gainers)),
      expect: () => [
        isA<DashboardLoaded>()
            .having((s) => s.selectedCategory, 'selectedCategory',
                AssetFilterCategory.gainers)
            .having((s) => s.assets.every((a) => a.changePercentage > 0),
                'all gainers', true),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits updated state when ToggleBalanceVisibility is added',
      build: () => bloc,
      seed: () => DashboardLoaded(
        stats: const DashboardStatsStub(),
        assets: const [],
        activities: const [],
        chartData: const PortfolioChartDataStub(),
        isBalanceVisible: true,
      ),
      act: (bloc) => bloc.add(const ToggleBalanceVisibility()),
      expect: () => [
        isA<DashboardLoaded>()
            .having((s) => s.isBalanceVisible, 'isBalanceVisible', false),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits new DashboardLoaded on RefreshDashboard',
      build: () => bloc,
      seed: () => DashboardLoaded(
        stats: const DashboardStatsStub(),
        assets: const [],
        activities: const [],
        chartData: const PortfolioChartDataStub(),
      ),
      act: (bloc) => bloc.add(const RefreshDashboard()),
      expect: () => [
        isA<DashboardLoaded>()
            .having((s) => s.stats.portfolioValue, 'portfolioValue', 8040215),
      ],
    );
  });
}

// Stubs for seeding states

class DashboardStatsStub extends DashboardStats {
  const DashboardStatsStub()
      : super(
          portfolioValue: 100,
          totalReturn: 10,
          returnPercentage: 1.0,
          cryptoBalance: 80,
          cashBalance: 20,
        );
}

class PortfolioChartDataStub extends PortfolioChartData {
  const PortfolioChartDataStub()
      : super(
          points: const [],
          minValue: 0,
          maxValue: 100,
        );
}
