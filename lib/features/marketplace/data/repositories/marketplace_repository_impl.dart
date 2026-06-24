import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_review.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/product_review_model.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  MarketplaceRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Not authenticated');
    return id;
  }

  // ---------------------------------------------------------------- catalog
  @override
  Future<Either<Failure, List<Product>>> getProducts(
    ProductFilter filter,
  ) async {
    try {
      var query = _client
          .from(AppConstants.tProducts)
          .select()
          .eq('is_active', true)
          .eq('category', filter.category.name);

      if (filter.subcategory != null) {
        query = query.eq('subcategory', filter.subcategory!);
      }
      if (filter.search.trim().isNotEmpty) {
        query = query.ilike('title', '%${filter.search.trim()}%');
      }
      if (filter.inStockOnly) {
        query = query.gt('stock', 0);
      }

      final rows = await switch (filter.sort) {
        ProductSort.newest => query.order('created_at', ascending: false),
        ProductSort.priceAsc => query.order('price', ascending: true),
        ProductSort.priceDesc => query.order('price', ascending: false),
        ProductSort.topRated => query.order('rating', ascending: false),
      };
      return Right(rows.map(ProductModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final row = await _client
          .from(AppConstants.tProducts)
          .select()
          .eq('id', id)
          .single();
      return Right(ProductModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ---------------------------------------------------------------- reviews
  @override
  Future<Either<Failure, List<ProductReview>>> getReviews(
    String productId,
  ) async {
    try {
      final rows = await _client
          .from(AppConstants.tProductReviews)
          .select('*, profiles(full_name)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return Right(rows.map(ProductReviewModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> submitReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _client.from(AppConstants.tProductReviews).upsert({
        'product_id': productId,
        'user_id': _uid,
        'rating': rating,
        'comment': comment,
      }, onConflict: 'product_id,user_id');
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // -------------------------------------------------------------- favorites
  @override
  Future<Either<Failure, Set<String>>> getFavoriteIds() async {
    try {
      final rows = await _client
          .from(AppConstants.tFavorites)
          .select('product_id')
          .eq('user_id', _uid);
      return Right({for (final r in rows) r['product_id'] as String});
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getFavoriteProducts() async {
    try {
      final rows = await _client
          .from(AppConstants.tFavorites)
          .select('products(*)')
          .eq('user_id', _uid);
      final products = rows
          .map((r) => r['products'])
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
      return Right(products);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleFavorite(
    String productId,
    bool favorite,
  ) async {
    try {
      if (favorite) {
        await _client.from(AppConstants.tFavorites).upsert({
          'user_id': _uid,
          'product_id': productId,
        }, onConflict: 'user_id,product_id');
      } else {
        await _client
            .from(AppConstants.tFavorites)
            .delete()
            .eq('user_id', _uid)
            .eq('product_id', productId);
      }
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ------------------------------------------------------------------- cart
  @override
  Future<Either<Failure, List<CartItem>>> getCart() async {
    try {
      final rows = await _client
          .from(AppConstants.tCartItems)
          .select('quantity, products(*)')
          .eq('user_id', _uid)
          .order('created_at');
      final items = <CartItem>[];
      for (final r in rows) {
        final product = r['products'];
        if (product is Map<String, dynamic>) {
          items.add(CartItem(
            product: ProductModel.fromJson(product),
            quantity: (r['quantity'] as num).toInt(),
          ));
        }
      }
      return Right(items);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setCartItem(
    String productId,
    int quantity,
  ) async {
    try {
      await _client.from(AppConstants.tCartItems).upsert({
        'user_id': _uid,
        'product_id': productId,
        'quantity': quantity,
      }, onConflict: 'user_id,product_id');
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeCartItem(String productId) async {
    try {
      await _client
          .from(AppConstants.tCartItems)
          .delete()
          .eq('user_id', _uid)
          .eq('product_id', productId);
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCart() async {
    try {
      await _client
          .from(AppConstants.tCartItems)
          .delete()
          .eq('user_id', _uid);
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // -------------------------------------------------------- orders/checkout
  @override
  Future<Either<Failure, String>> checkout(List<CartItem> items) async {
    try {
      final payload = items
          .map((e) => {'product_id': e.product.id, 'quantity': e.quantity})
          .toList();
      final orderId =
          await _client.rpc('place_order', params: {'p_items': payload});
      return Right(orderId as String);
    } on PostgrestException catch (e) {
      // Surface domain errors raised by the RPC (e.g. insufficient balance).
      return Left(_mapRpcError(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MarketOrder>>> getOrders() async {
    try {
      final rows = await _client
          .from(AppConstants.tOrders)
          .select('*, order_items(quantity, unit_price, products(title, image_url))')
          .eq('user_id', _uid)
          .order('created_at', ascending: false);
      return Right(rows.map(OrderModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MarketOrder>> getOrder(String id) async {
    try {
      final row = await _client
          .from(AppConstants.tOrders)
          .select('*, order_items(quantity, unit_price, products(title, image_url))')
          .eq('id', id)
          .single();
      return Right(OrderModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Failure _mapRpcError(String message) {
    if (message.contains('insufficient wallet balance')) {
      return const ValidationFailure('موجودی کیف پول کافی نیست');
    }
    if (message.contains('insufficient stock')) {
      return const ValidationFailure('موجودی انبار کافی نیست');
    }
    if (message.contains('cart is empty')) {
      return const ValidationFailure('سبد خرید خالی است');
    }
    return const ServerFailure();
  }
}
