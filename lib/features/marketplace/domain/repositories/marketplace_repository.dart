import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';
import '../entities/order.dart';
import '../entities/product.dart';
import '../entities/product_filter.dart';
import '../entities/product_review.dart';

abstract interface class MarketplaceRepository {
  // --- Catalog ---
  Future<Either<Failure, List<Product>>> getProducts(ProductFilter filter);
  Future<Either<Failure, Product>> getProduct(String id);

  // --- Reviews ---
  Future<Either<Failure, List<ProductReview>>> getReviews(String productId);
  Future<Either<Failure, Unit>> submitReview({
    required String productId,
    required int rating,
    String? comment,
  });

  // --- Favorites ---
  Future<Either<Failure, Set<String>>> getFavoriteIds();
  Future<Either<Failure, List<Product>>> getFavoriteProducts();
  Future<Either<Failure, Unit>> toggleFavorite(String productId, bool favorite);

  // --- Cart ---
  Future<Either<Failure, List<CartItem>>> getCart();
  Future<Either<Failure, Unit>> setCartItem(String productId, int quantity);
  Future<Either<Failure, Unit>> removeCartItem(String productId);
  Future<Either<Failure, Unit>> clearCart();

  // --- Orders / checkout ---
  /// Places an order from [items] via the `place_order` RPC; returns order id.
  Future<Either<Failure, String>> checkout(List<CartItem> items);
  Future<Either<Failure, List<MarketOrder>>> getOrders();
  Future<Either<Failure, MarketOrder>> getOrder(String id);
}
