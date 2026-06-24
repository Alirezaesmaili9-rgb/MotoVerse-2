import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/marketplace_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_review.dart';
import '../../domain/repositories/marketplace_repository.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Current listing filter (category, subcategory, search, sort).
final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
  ProductFilterNotifier.new,
);

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() =>
      const ProductFilter(category: ProductCategory.parts);

  void setCategory(ProductCategory c) =>
      state = ProductFilter(category: c); // reset sub/search on vertical switch

  void setSubcategory(String? key) => state = key == null
      ? state.copyWith(clearSubcategory: true)
      : state.copyWith(subcategory: key);

  void setSearch(String q) => state = state.copyWith(search: q);

  void setSort(ProductSort s) => state = state.copyWith(sort: s);

  void toggleInStock() =>
      state = state.copyWith(inStockOnly: !state.inStockOnly);
}

/// Products matching the active filter.
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final filter = ref.watch(productFilterProvider);
  final res = await ref.watch(marketplaceRepositoryProvider).getProducts(filter);
  return res.fold((f) => throw Exception(f.message), (p) => p);
});

/// A single product (detail screen).
final productProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  final res = await ref.watch(marketplaceRepositoryProvider).getProduct(id);
  return res.fold((f) => throw Exception(f.message), (p) => p);
});

/// Reviews for a product.
final reviewsProvider = FutureProvider.autoDispose
    .family<List<ProductReview>, String>((ref, productId) async {
  final res =
      await ref.watch(marketplaceRepositoryProvider).getReviews(productId);
  return res.fold((f) => throw Exception(f.message), (r) => r);
});

/// Submits/updates the current user's review, then refreshes.
final submitReviewProvider = Provider((ref) => _SubmitReview(ref));

class _SubmitReview {
  _SubmitReview(this.ref);
  final Ref ref;

  Future<String?> call({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    final res = await ref.read(marketplaceRepositoryProvider).submitReview(
          productId: productId,
          rating: rating,
          comment: comment,
        );
    return res.fold((f) => f.message, (_) {
      ref.invalidate(reviewsProvider(productId));
      ref.invalidate(productProvider(productId));
      return null;
    });
  }
}

/// Set of favorited product ids — drives the heart toggle everywhere.
final favoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsNotifier, Set<String>>(
  FavoriteIdsNotifier.new,
);

class FavoriteIdsNotifier extends AsyncNotifier<Set<String>> {
  MarketplaceRepository get _repo => ref.read(marketplaceRepositoryProvider);

  @override
  Future<Set<String>> build() async {
    ref.watch(authStateChangesProvider);
    final res = await _repo.getFavoriteIds();
    return res.fold((_) => <String>{}, (ids) => ids);
  }

  Future<void> toggle(String productId) async {
    final current = {...(state.valueOrNull ?? <String>{})};
    final willFavorite = !current.contains(productId);
    // Optimistic update.
    willFavorite ? current.add(productId) : current.remove(productId);
    state = AsyncValue.data(current);

    final res = await _repo.toggleFavorite(productId, willFavorite);
    res.fold((_) => ref.invalidateSelf(), (_) {
      ref.invalidate(favoriteProductsProvider);
    });
  }

  bool isFavorite(String id) => (state.valueOrNull ?? const {}).contains(id);
}

/// Full product objects for the Favorites screen.
final favoriteProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  ref.watch(favoriteIdsProvider);
  final res =
      await ref.watch(marketplaceRepositoryProvider).getFavoriteProducts();
  return res.fold((f) => throw Exception(f.message), (p) => p);
});
