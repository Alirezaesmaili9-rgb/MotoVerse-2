import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/product.dart';
import '../providers/cart_providers.dart';
import '../providers/marketplace_providers.dart';
import 'category_theme.dart';

/// Product tile used in grids/rows. Shows favorite toggle, rating, price and a
/// quick "add to cart" action.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoriteIdsProvider).valueOrNull ?? const {};
    final isFav = favIds.contains(product.id);
    final accent = CategoryTheme.color(product.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 104,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  alignment: Alignment.center,
                  child: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(product.imageUrl!,
                              height: 104,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        )
                      : Text(CategoryTheme.emoji(product.category),
                          style: const TextStyle(fontSize: 34)),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => ref
                          .read(favoriteIdsProvider.notifier)
                          .toggle(product.id),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 17,
                          color: isFav ? AppColors.danger : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 13, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(PersianUtils.toFa(product.rating.toStringAsFixed(1)),
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    PersianUtils.formatToman(product.price),
                    style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: FilledButton(
                      onPressed: product.inStock
                          ? () {
                              ref.read(cartProvider.notifier).add(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('به سبد خرید اضافه شد'),
                                ),
                              );
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent.withOpacity(0.12),
                        foregroundColor: accent,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(product.inStock ? 'افزودن' : 'ناموجود',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
