import '../entities/activity.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentActivities {
  final DashboardRepository repository;

  GetRecentActivities(this.repository);

  Future<List<Activity>> call({int page = 0, int limit = 20}) async {
    return await repository.getRecentActivities(page: page, limit: limit);
  }
}
