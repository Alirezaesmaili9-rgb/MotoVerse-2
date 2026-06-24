import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../marketplace/data/models/order_model.dart';
import '../../../marketplace/data/models/product_model.dart';
import '../../../marketplace/domain/entities/order.dart';
import '../../../marketplace/domain/entities/product.dart';
import '../../../motor_world/data/models/news_article_model.dart';
import '../../../motor_world/domain/entities/news_article.dart';
import '../../../roadside/data/models/roadside_request_model.dart';
import '../../../roadside/domain/entities/roadside_request.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Either<Failure, AdminStats>> getStats() async {
    try {
      final res = await _client.rpc('admin_stats') as Map<String, dynamic>;
      return Right(AdminStats(
        users: (res['users'] as num?)?.toInt() ?? 0,
        products: (res['products'] as num?)?.toInt() ?? 0,
        orders: (res['orders'] as num?)?.toInt() ?? 0,
        revenue: (res['revenue'] as num?)?.toInt() ?? 0,
        activeRoadside: (res['active_roadside'] as num?)?.toInt() ?? 0,
        pendingBookings: (res['pending_bookings'] as num?)?.toInt() ?? 0,
        policies: (res['policies'] as num?)?.toInt() ?? 0,
        news: (res['news'] as num?)?.toInt() ?? 0,
      ));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ------------------------------------------------------------------- users
  @override
  Future<Either<Failure, List<AdminUser>>> getUsers() async {
    try {
      final rows = await _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      return Right(rows
          .map((r) => AdminUser(
                id: r['id'] as String,
                role: r['role'] as String? ?? 'rider',
                fullName: r['full_name'] as String?,
                phone: r['phone'] as String?,
                walletBalance: (r['wallet_balance'] as num?)?.toInt() ?? 0,
                createdAt: r['created_at'] == null
                    ? null
                    : DateTime.parse(r['created_at'] as String),
              ))
          .toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setUserRole(String userId, String role) =>
      _run(() => _client.from('profiles').update({'role': role}).eq('id', userId));

  @override
  Future<Either<Failure, Unit>> sendNotification({
    required String userId,
    required String title,
    String? body,
    String type = 'general',
  }) =>
      _run(() => _client.from('notifications').insert({
            'user_id': userId,
            'title': title,
            'body': body,
            'type': type,
          }));

  // ---------------------------------------------------------------- products
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final rows = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);
      return Right(rows.map(ProductModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertProduct(Map<String, dynamic> data) =>
      _run(() => _client.from('products').upsert(data));

  @override
  Future<Either<Failure, Unit>> deleteProduct(String id) =>
      _run(() => _client.from('products').delete().eq('id', id));

  // -------------------------------------------------------------------- news
  @override
  Future<Either<Failure, List<NewsArticle>>> getNews() async {
    try {
      final rows = await _client
          .from('news_articles')
          .select()
          .order('published_at', ascending: false);
      return Right(rows.map(NewsArticleModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertNews(Map<String, dynamic> data) =>
      _run(() => _client.from('news_articles').upsert(data));

  @override
  Future<Either<Failure, Unit>> deleteNews(String id) =>
      _run(() => _client.from('news_articles').delete().eq('id', id));

  // ------------------------------------------------------------------ orders
  @override
  Future<Either<Failure, List<MarketOrder>>> getOrders() async {
    try {
      final rows = await _client
          .from('orders')
          .select(
              '*, order_items(quantity, unit_price, products(title, image_url))')
          .order('created_at', ascending: false);
      return Right(rows.map(OrderModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setOrderStatus(String id, String status) =>
      _run(() =>
          _client.from('orders').update({'status': status}).eq('id', id));

  // ---------------------------------------------------------------- roadside
  @override
  Future<Either<Failure, List<RoadsideRequest>>> getRoadside() async {
    try {
      final rows = await _client
          .from('roadside_requests')
          .select()
          .order('created_at', ascending: false);
      return Right(rows.map(RoadsideRequestModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateRoadside(
    String id, {
    String? status,
    int? etaMinutes,
  }) =>
      _run(() => _client.from('roadside_requests').update({
            if (status != null) 'status': status,
            if (etaMinutes != null) 'eta_minutes': etaMinutes,
          }).eq('id', id));

  /// Wraps a fire-and-forget mutation, mapping exceptions to a [Failure].
  Future<Either<Failure, Unit>> _run(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
