import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/motorcycle.dart';
import '../../domain/repositories/garage_repository.dart';
import '../models/motorcycle_model.dart';

class GarageRepositoryImpl implements GarageRepository {
  GarageRepositoryImpl(this._client);

  final SupabaseClient _client;

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tMotorcycles);

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Not authenticated');
    return id;
  }

  @override
  Future<Either<Failure, List<Motorcycle>>> getMotorcycles() async {
    try {
      final rows = await _table
          .select()
          .eq('owner_id', _uid)
          .order('is_primary', ascending: false)
          .order('created_at');
      return Right(rows.map(MotorcycleModel.fromJson).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Motorcycle>> addMotorcycle(Motorcycle bike) async {
    try {
      final payload = MotorcycleModel.toJson(bike)..['owner_id'] = _uid;
      final row = await _table.insert(payload).select().single();
      return Right(MotorcycleModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Motorcycle>> updateMotorcycle(Motorcycle bike) async {
    try {
      final row = await _table
          .update(MotorcycleModel.toJson(bike))
          .eq('id', bike.id)
          .eq('owner_id', _uid)
          .select()
          .single();
      return Right(MotorcycleModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMotorcycle(String id) async {
    try {
      await _table.delete().eq('id', id).eq('owner_id', _uid);
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMileage(String id, int mileage) async {
    try {
      await _table
          .update({'mileage': mileage})
          .eq('id', id)
          .eq('owner_id', _uid);
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
