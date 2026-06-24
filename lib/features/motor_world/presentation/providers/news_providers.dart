import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/repositories/news_repository.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Active tag filter (null = all).
final newsTagFilterProvider = StateProvider<String?>((ref) => null);

final newsArticlesProvider =
    FutureProvider.autoDispose<List<NewsArticle>>((ref) async {
  final tag = ref.watch(newsTagFilterProvider);
  final res = await ref.watch(newsRepositoryProvider).getArticles(tag: tag);
  return res.fold((f) => throw Exception(f.message), (a) => a);
});

final newsTagsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final res = await ref.watch(newsRepositoryProvider).getTags();
  return res.fold((_) => <String>[], (t) => t);
});

/// Latest few articles for the home banner.
final latestNewsProvider =
    FutureProvider.autoDispose<List<NewsArticle>>((ref) async {
  final res = await ref.watch(newsRepositoryProvider).getArticles();
  return res.fold((_) => <NewsArticle>[], (a) => a.take(5).toList());
});

final articleProvider =
    FutureProvider.autoDispose.family<NewsArticle, String>((ref, id) async {
  final res = await ref.watch(newsRepositoryProvider).getArticle(id);
  return res.fold((f) => throw Exception(f.message), (a) => a);
});
