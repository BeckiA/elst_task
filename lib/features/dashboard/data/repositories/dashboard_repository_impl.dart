import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/portfolio_chart_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/value_objects/filter_values.dart';
import '../datasources/mock_dashboard_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource dataSource;

  DashboardRepositoryImpl({required this.dataSource});

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      return await dataSource.getDashboardStats();
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  @override
  Future<List<Asset>> getAssets({AssetFilterCategory? category}) async {
    try {
      return await dataSource.getAssets(category: category);
    } catch (e) {
      throw Exception('Failed to fetch assets: $e');
    }
  }

  @override
  Future<List<Activity>> getRecentActivities({
    int page = 0,
    int limit = 20,
  }) async {
    try {
      return await dataSource.getRecentActivities(page: page, limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch activities: $e');
    }
  }

  @override
  Future<PortfolioChartData> getPortfolioChartData({
    TimeRange range = TimeRange.month,
  }) async {
    try {
      return await dataSource.getPortfolioChartData(range: range);
    } catch (e) {
      throw Exception('Failed to fetch chart data: $e');
    }
  }
}
