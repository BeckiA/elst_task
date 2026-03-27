import '../entities/dashboard_stats.dart';
import '../entities/asset.dart';
import '../entities/activity.dart';
import '../entities/portfolio_chart_data.dart';
import '../value_objects/filter_values.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();
  Future<List<Asset>> getAssets({AssetFilterCategory? category});
  Future<List<Activity>> getRecentActivities({int page = 0, int limit = 20});
  Future<PortfolioChartData> getPortfolioChartData({TimeRange range = TimeRange.month});
}
