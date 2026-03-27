import '../entities/news_article.dart';
import '../repositories/dashboard_repository.dart';

class GetNews {
  final DashboardRepository repository;

  GetNews(this.repository);

  Future<List<NewsArticle>> call() async {
    return await repository.getNews();
  }
}
