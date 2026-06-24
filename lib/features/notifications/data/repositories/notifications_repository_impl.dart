import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../models/app_notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._client);

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      final uid = _uid;
      if (uid == null) return const Left(AuthFailure());
      final rows = await _client
          .from(AppConstants.tNotifications)
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      return Right(rows.map(AppNotificationModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markRead(String id) async {
    try {
      await _client
          .from(AppConstants.tNotifications)
          .update({'is_read': true}).eq('id', id);
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() async {
    try {
      final uid = _uid;
      if (uid == null) return const Left(AuthFailure());
      await _client
          .from(AppConstants.tNotifications)
          .update({'is_read': true})
          .eq('user_id', uid)
          .eq('is_read', false);
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<int> watchUnreadCount() {
    final uid = _uid;
    if (uid == null) return Stream.value(0);
    return _client
        .from(AppConstants.tNotifications)
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .map((rows) =>
            rows.where((r) => r['is_read'] == false).length);
  }
}
