import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../marketplace/domain/entities/order.dart';
import '../../../marketplace/domain/entities/product.dart';
import '../../../motor_world/domain/entities/news_article.dart';
import '../../../roadside/domain/entities/roadside_request.dart';
import '../entities/admin_stats.dart';
import '../entities/admin_user.dart';

/// Admin operations. All calls rely on the caller being an admin; the
/// is_admin()-guarded RLS policies enforce this server-side.
abstract interface class AdminRepository {
  Future<Either<Failure, AdminStats>> getStats();

  // Users
  Future<Either<Failure, List<AdminUser>>> getUsers();
  Future<Either<Failure, Unit>> setUserRole(String userId, String role);
  Future<Either<Failure, Unit>> sendNotification({
    required String userId,
    required String title,
    String? body,
    String type = 'general',
  });

  // Products (marketplace management)
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Unit>> upsertProduct(Map<String, dynamic> data);
  Future<Either<Failure, Unit>> deleteProduct(String id);

  // News management
  Future<Either<Failure, List<NewsArticle>>> getNews();
  Future<Either<Failure, Unit>> upsertNews(Map<String, dynamic> data);
  Future<Either<Failure, Unit>> deleteNews(String id);

  // Orders
  Future<Either<Failure, List<MarketOrder>>> getOrders();
  Future<Either<Failure, Unit>> setOrderStatus(String id, String status);

  // Roadside
  Future<Either<Failure, List<RoadsideRequest>>> getRoadside();
  Future<Either<Failure, Unit>> updateRoadside(
    String id, {
    String? status,
    int? etaMinutes,
  });
}
