import '../entities/portfolio_chart_data.dart';
import '../repositories/dashboard_repository.dart';
import '../value_objects/filter_values.dart';

class GetPortfolioChartData {
  final DashboardRepository repository;

  GetPortfolioChartData(this.repository);

  Future<PortfolioChartData> call({TimeRange range = TimeRange.month}) async {
    return await repository.getPortfolioChartData(range: range);
  }
}
