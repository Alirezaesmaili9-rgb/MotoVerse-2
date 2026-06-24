import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';
import '../models/news_article_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Either<Failure, List<NewsArticle>>> getArticles({String? tag}) async {
    try {
      var q = _client
          .from(AppConstants.tNewsArticles)
          .select()
          .eq('is_published', true);
      if (tag != null && tag.isNotEmpty) {
        q = q.eq('tag', tag);
      }
      final rows = await q.order('published_at', ascending: false);
      return Right(rows.map(NewsArticleModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, NewsArticle>> getArticle(String id) async {
    try {
      final row = await _client
          .from(AppConstants.tNewsArticles)
          .select()
          .eq('id', id)
          .single();
      return Right(NewsArticleModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getTags() async {
    try {
      final rows = await _client
          .from(AppConstants.tNewsArticles)
          .select('tag')
          .eq('is_published', true);
      final tags = <String>{
        for (final r in rows)
          if (r['tag'] != null) r['tag'] as String,
      };
      return Right(tags.toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
