import '../entities/dashboard_stats.dart';
import '../entities/asset.dart';
import '../entities/asset_detail.dart';
import '../entities/news_article.dart';
import '../entities/portfolio_chart_data.dart';
import '../value_objects/chart_timeframe.dart';
import '../value_objects/filter_values.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();
  Future<List<Asset>> getAssets({AssetFilterCategory? category});
  Future<AssetDetail> getAssetDetail(
    String assetId, {
    required ChartTimeframe timeframe,
  });
  Future<PortfolioChartData> getPortfolioChartData({TimeRange range = TimeRange.month});
  Future<List<NewsArticle>> getNews();
}
