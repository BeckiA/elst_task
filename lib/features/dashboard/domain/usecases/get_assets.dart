import '../entities/asset.dart';
import '../repositories/dashboard_repository.dart';
import '../value_objects/filter_values.dart';

class GetAssets {
  final DashboardRepository repository;

  GetAssets(this.repository);

  Future<List<Asset>> call({AssetFilterCategory? category}) async {
    return await repository.getAssets(category: category);
  }
}
