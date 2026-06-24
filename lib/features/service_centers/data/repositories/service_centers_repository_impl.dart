import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/service_booking.dart';
import '../../domain/entities/service_center.dart';
import '../../domain/repositories/service_centers_repository.dart';
import '../models/service_center_model.dart';

class ServiceCentersRepositoryImpl implements ServiceCentersRepository {
  ServiceCentersRepositoryImpl(this._client);

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<ServiceCenter>>> getCenters({
    String? query,
  }) async {
    try {
      var q = _client.from('service_centers').select();
      if (query != null && query.trim().isNotEmpty) {
        q = q.ilike('name', '%${query.trim()}%');
      }
      final rows = await q.order('rating', ascending: false);
      return Right(rows.map(ServiceCenterModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ServiceBooking>>> getBookings() async {
    try {
      final uid = _uid;
      if (uid == null) return const Left(AuthFailure());
      final rows = await _client
          .from('service_bookings')
          .select('*, service_centers(name)')
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      return Right(rows.map(ServiceBookingModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ServiceBooking>> book({
    required String serviceCenterId,
    String? motorcycleId,
    DateTime? scheduledAt,
    String? notes,
  }) async {
    try {
      final uid = _uid;
      if (uid == null) return const Left(AuthFailure());
      final row = await _client
          .from('service_bookings')
          .insert({
            'user_id': uid,
            'service_center_id': serviceCenterId,
            'motorcycle_id': motorcycleId,
            'scheduled_at': scheduledAt?.toIso8601String(),
            'notes': notes,
            'status': 'requested',
          })
          .select('*, service_centers(name)')
          .single();
      return Right(ServiceBookingModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
