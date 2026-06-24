import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../marketplace/domain/entities/order.dart';
import '../../../marketplace/domain/entities/product.dart';
import '../../../motor_world/domain/entities/news_article.dart';
import '../../../roadside/domain/entities/roadside_request.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Whether the signed-in user is an admin (gates the dashboard entry).
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(appUserProvider).valueOrNull?.isAdmin ?? false;
});

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) async {
  final res = await ref.watch(adminRepositoryProvider).getStats();
  return res.fold((f) => throw Exception(f.message), (s) => s);
});

final adminUsersProvider =
    FutureProvider.autoDispose<List<AdminUser>>((ref) async {
  final res = await ref.watch(adminRepositoryProvider).getUsers();
  return res.fold((f) => throw Exception(f.message), (u) => u);
});

final adminProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final res = await ref.watch(adminRepositoryProvider).getProducts();
  return res.fold((f) => throw Exception(f.message), (p) => p);
});

final adminNewsProvider =
    FutureProvider.autoDispose<List<NewsArticle>>((ref) async {
  final res = await ref.watch(adminRepositoryProvider).getNews();
  return res.fold((f) => throw Exception(f.message), (n) => n);
});

final adminOrdersProvider =
    FutureProvider.autoDispose<List<MarketOrder>>((ref) async {
  final res = await ref.watch(adminRepositoryProvider).getOrders();
  return res.fold((f) => throw Exception(f.message), (o) => o);
});

final adminRoadsideProvider =
    FutureProvider.autoDispose<List<RoadsideRequest>>((ref) async {
  final res = await ref.watch(adminRepositoryProvider).getRoadside();
  return res.fold((f) => throw Exception(f.message), (r) => r);
});

/// Mutations + targeted invalidation.
final adminActionsProvider = Provider((ref) => AdminActions(ref));

class AdminActions {
  AdminActions(this.ref);
  final Ref ref;

  AdminRepository get _repo => ref.read(adminRepositoryProvider);

  Future<String?> setUserRole(String userId, String role) async {
    final res = await _repo.setUserRole(userId, role);
    return res.fold((f) => f.message, (_) {
      ref.invalidate(adminUsersProvider);
      ref.invalidate(adminStatsProvider);
      return null;
    });
  }

  Future<String?> sendNotification({
    required String userId,
    required String title,
    String? body,
  }) async {
    final res =
        await _repo.sendNotification(userId: userId, title: title, body: body);
    return res.fold((f) => f.message, (_) => null);
  }

  Future<String?> saveProduct(Map<String, dynamic> data) async {
    final res = await _repo.upsertProduct(data);
    return res.fold((f) => f.message, (_) {
      ref.invalidate(adminProductsProvider);
      return null;
    });
  }

  Future<void> deleteProduct(String id) async {
    await _repo.deleteProduct(id);
    ref.invalidate(adminProductsProvider);
  }

  Future<String?> saveNews(Map<String, dynamic> data) async {
    final res = await _repo.upsertNews(data);
    return res.fold((f) => f.message, (_) {
      ref.invalidate(adminNewsProvider);
      return null;
    });
  }

  Future<void> deleteNews(String id) async {
    await _repo.deleteNews(id);
    ref.invalidate(adminNewsProvider);
  }

  Future<void> setOrderStatus(String id, String status) async {
    await _repo.setOrderStatus(id, status);
    ref.invalidate(adminOrdersProvider);
    ref.invalidate(adminStatsProvider);
  }

  Future<void> updateRoadside(String id,
      {String? status, int? etaMinutes}) async {
    await _repo.updateRoadside(id, status: status, etaMinutes: etaMinutes);
    ref.invalidate(adminRoadsideProvider);
    ref.invalidate(adminStatsProvider);
  }
}
