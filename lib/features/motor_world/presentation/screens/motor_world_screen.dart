import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/news_article.dart';
import '../providers/news_providers.dart';

/// Motor World — Iranian & global motorcycle news.
class MotorWorldScreen extends ConsumerWidget {
  const MotorWorldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(newsArticlesProvider);
    final tags = ref.watch(newsTagsProvider).valueOrNull ?? const [];
    final activeTag = ref.watch(newsTagFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('دنیای موتور')),
      body: Column(
        children: [
          if (tags.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: ChoiceChip(
                      label: const Text('همه'),
                      selected: activeTag == null,
                      onSelected: (_) =>
                          ref.read(newsTagFilterProvider.notifier).state = null,
                    ),
                  ),
                  for (final t in tags)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8),
                      child: ChoiceChip(
                        label: Text(t),
                        selected: activeTag == t,
                        onSelected: (_) => ref
                            .read(newsTagFilterProvider.notifier)
                            .state = t,
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: articles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطا: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('خبری یافت نشد'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => NewsCard(article: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final date =
        PersianUtils.toFa(intl.DateFormat('yyyy/MM/dd').format(article.publishedAt));

    return InkWell(
      onTap: () =>
          context.push(AppRoutes.newsArticle, extra: article.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.tag != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(article.tag!,
                    style: const TextStyle(
                        color: AppColors.primaryHover,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 8),
            Text(article.title,
                style: Theme.of(context).textTheme.titleSmall),
            if (article.summary != null) ...[
              const SizedBox(height: 4),
              Text(article.summary!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (article.source != null)
                  Text(article.source!,
                      style: Theme.of(context).textTheme.labelSmall),
                const Spacer(),
                Text(date, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
