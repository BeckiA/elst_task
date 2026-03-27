import '../entities/asset_detail.dart';
import '../repositories/dashboard_repository.dart';
import '../value_objects/chart_timeframe.dart';

class GetAssetDetail {
  final DashboardRepository repository;

  GetAssetDetail(this.repository);

  Future<AssetDetail> call(
    String assetId, {
    required ChartTimeframe timeframe,
  }) {
    return repository.getAssetDetail(assetId, timeframe: timeframe);
  }
}
