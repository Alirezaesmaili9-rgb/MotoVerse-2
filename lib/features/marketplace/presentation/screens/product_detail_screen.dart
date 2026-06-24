import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_review.dart';
import '../providers/cart_providers.dart';
import '../providers/marketplace_providers.dart';
import '../widgets/category_theme.dart';
import '../widgets/review_composer.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(productId));
    final reviewsAsync = ref.watch(reviewsProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات محصول'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (product) {
          final accent = CategoryTheme.color(product.category);
          final favIds = ref.watch(favoriteIdsProvider).valueOrNull ?? const {};
          final isFav = favIds.contains(product.id);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(product.imageUrl!,
                                  fit: BoxFit.cover, width: double.infinity),
                            )
                          : Text(CategoryTheme.emoji(product.category),
                              style: const TextStyle(fontSize: 64)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(product.title,
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(favoriteIdsProvider.notifier)
                              .toggle(product.id),
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? AppColors.danger : null,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          PersianUtils.toFa(product.rating.toStringAsFixed(1)),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 12),
                        _StockBadge(inStock: product.inStock),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(PersianUtils.formatToman(product.price),
                        style: TextStyle(
                            color: accent,
                            fontSize: 22,
                            fontWeight: FontWeight.w900)),
                    if (product.description != null) ...[
                      const SizedBox(height: 16),
                      Text('توضیحات',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(product.description!,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 20),
                    _ReviewsSection(
                      productId: product.id,
                      reviews: reviewsAsync,
                    ),
                  ],
                ),
              ),
              _BuyBar(product: product, accent: accent),
            ],
          );
        },
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.inStock});
  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final color = inStock ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(inStock ? 'موجود' : 'ناموجود',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({required this.productId, required this.reviews});

  final String productId;
  final AsyncValue<List<ProductReview>> reviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('نظرات کاربران',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ReviewComposer(productId: productId),
              ),
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('ثبت نظر'),
            ),
          ],
        ),
        reviews.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('خطا: $e'),
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('هنوز نظری ثبت نشده است. اولین نفر باشید!'),
              );
            }
            return Column(
              children: [for (final r in list) _ReviewTile(review: r)],
            );
          },
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.authorName ?? 'کاربر MotoVerse',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              for (var i = 0; i < 5; i++)
                Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: AppColors.warning,
                ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.comment!,
                style: Theme.of(context).textTheme.bodySmall),
          ],
          const Divider(height: 16),
        ],
      ),
    );
  }
}

class _BuyBar extends ConsumerWidget {
  const _BuyBar({required this.product, required this.accent});
  final Product product;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: product.inStock
                    ? () {
                        ref.read(cartProvider.notifier).add(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text('به سبد خرید اضافه شد ✓'),
                          ),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(product.inStock ? 'افزودن به سبد خرید' : 'ناموجود'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
