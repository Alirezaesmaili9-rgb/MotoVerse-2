import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../providers/news_providers.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(articleProvider(articleId));

    return Scaffold(
      appBar: AppBar(title: const Text('دنیای موتور')),
      body: article.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (a) {
          final date = PersianUtils.toFa(
              intl.DateFormat('yyyy/MM/dd').format(a.publishedAt));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (a.coverUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(a.coverUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              if (a.tag != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(a.tag!,
                      style: const TextStyle(
                          color: AppColors.primaryHover,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              const SizedBox(height: 8),
              Text(a.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (a.source != null)
                    Text(a.source!,
                        style: Theme.of(context).textTheme.labelMedium),
                  const Spacer(),
                  Text(date, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              const Divider(height: 24),
              Text(a.body ?? a.summary ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.9)),
            ],
          );
        },
      ),
    );
  }
}
