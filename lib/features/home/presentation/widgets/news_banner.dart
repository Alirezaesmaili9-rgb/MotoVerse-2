import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../motor_world/presentation/providers/news_providers.dart';

/// Horizontal carousel of the latest Motor World headlines for the home screen.
class HomeNewsBanner extends ConsumerWidget {
  const HomeNewsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(latestNewsProvider);

    return news.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final a = list[i];
              return GestureDetector(
                onTap: () =>
                    context.push(AppRoutes.newsArticle, extra: a.id),
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.tag != null)
                        Text(a.tag!,
                            style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          a.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.5),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (a.source != null)
                        Text(a.source!,
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 11)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
