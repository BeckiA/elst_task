import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStats {
  final DashboardRepository repository;

  GetDashboardStats(this.repository);

  Future<DashboardStats> call() async {
    return await repository.getDashboardStats();
  }
}
