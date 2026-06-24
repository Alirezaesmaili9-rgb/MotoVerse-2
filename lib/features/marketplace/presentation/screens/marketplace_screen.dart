import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../providers/cart_providers.dart';
import '../providers/marketplace_providers.dart';
import '../widgets/category_theme.dart';
import '../widgets/product_card.dart';

/// Marketplace home: switch between Parts (purple) and Accessories (pink),
/// search, filter by category, sort, and browse the product grid.
class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterProvider);
    final notifier = ref.read(productFilterProvider.notifier);
    final products = ref.watch(productsProvider);
    final accent = CategoryTheme.color(filter.category);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مارکت‌پلیس'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.favorites),
            icon: const Icon(Icons.favorite_border),
          ),
          _CartButton(
            count: cartCount,
            onTap: () => context.push(AppRoutes.cart),
          ),
        ],
      ),
      body: Column(
        children: [
          // Vertical switch
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                for (final c in ProductCategory.values)
                  Expanded(
                    child: _VerticalTab(
                      category: c,
                      selected: filter.category == c,
                      onTap: () {
                        _searchCtrl.clear();
                        notifier.setCategory(c);
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: notifier.setSearch,
              decoration: InputDecoration(
                hintText: 'جستجو در ${filter.category.label}...',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          // Category chips + sort
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _Chip(
                  label: 'همه',
                  selected: filter.subcategory == null,
                  accent: accent,
                  onTap: () => notifier.setSubcategory(null),
                ),
                for (final sub in MarketplaceCategories.map[filter.category]!)
                  _Chip(
                    label: sub.label,
                    selected: filter.subcategory == sub.key,
                    accent: accent,
                    onTap: () => notifier.setSubcategory(sub.key),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                PopupMenuButton<ProductSort>(
                  initialValue: filter.sort,
                  onSelected: notifier.setSort,
                  itemBuilder: (_) => [
                    for (final s in ProductSort.values)
                      PopupMenuItem(value: s, child: Text(s.label)),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 18),
                      const SizedBox(width: 4),
                      Text(filter.sort.label,
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ),
                const Spacer(),
                FilterChip(
                  label: const Text('فقط موجود'),
                  selected: filter.inStockOnly,
                  onSelected: (_) => notifier.toggleInStock(),
                ),
              ],
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطا: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('محصولی یافت نشد'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: list[i],
                    onTap: () => context.push(
                      AppRoutes.productDetail,
                      extra: list[i].id,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalTab extends StatelessWidget {
  const _VerticalTab({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ProductCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CategoryTheme.gradient(category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: colors) : null,
          color: selected ? null : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(CategoryTheme.emoji(category),
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              category.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? accent : AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
            onPressed: onTap, icon: const Icon(Icons.shopping_cart_outlined)),
        if (count > 0)
          Positioned(
            top: 8,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: AppColors.danger, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 9 ? '+۹' : count.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  }
}
