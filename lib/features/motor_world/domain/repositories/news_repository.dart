import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/news_article.dart';

abstract interface class NewsRepository {
  /// Published articles, newest first; optionally filtered by [tag].
  Future<Either<Failure, List<NewsArticle>>> getArticles({String? tag});

  Future<Either<Failure, NewsArticle>> getArticle(String id);

  /// Distinct tags for the filter chips.
  Future<Either<Failure, List<String>>> getTags();
}
