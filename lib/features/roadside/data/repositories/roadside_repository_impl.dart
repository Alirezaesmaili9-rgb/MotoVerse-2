import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/roadside_request.dart';
import '../../domain/repositories/roadside_repository.dart';
import '../models/roadside_request_model.dart';

class RoadsideRepositoryImpl implements RoadsideRepository {
  RoadsideRepositoryImpl(this._client);

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, RoadsideRequest>> createRequest({
    required RoadsideKind kind,
    double? lat,
    double? lng,
  }) async {
    try {
      final uid = _uid;
      if (uid == null) return const Left(AuthFailure());
      final row = await _client
          .from('roadside_requests')
          .insert({
            'user_id': uid,
            'kind': kind.name,
            'lat': lat,
            'lng': lng,
            'status': 'requested',
          })
          .select()
          .single();
      return Right(RoadsideRequestModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<RoadsideRequest>>> getHistory() async {
    try {
      final uid = _uid;
      if (uid == null) return const Left(AuthFailure());
      final rows = await _client
          .from('roadside_requests')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      return Right(rows.map(RoadsideRequestModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> cancel(String id) async {
    try {
      await _client
          .from('roadside_requests')
          .update({'status': 'cancelled'}).eq('id', id);
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<RoadsideRequest> watch(String id) {
    return _client
        .from('roadside_requests')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .where((rows) => rows.isNotEmpty)
        .map((rows) => RoadsideRequestModel.fromJson(rows.first));
  }
}
