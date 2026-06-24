import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../models/maintenance_record_model.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl(this._client);

  final SupabaseClient _client;

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tMaintenanceRecords);

  @override
  Future<Either<Failure, List<MaintenanceRecord>>> getRecords(
    String motorcycleId,
  ) async {
    try {
      final rows = await _table
          .select()
          .eq('motorcycle_id', motorcycleId)
          .order('mileage', ascending: false);
      return Right(rows.map(MaintenanceRecordModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MaintenanceRecord>> addRecord(
    MaintenanceRecord record,
  ) async {
    try {
      final row = await _table
          .insert(MaintenanceRecordModel.toJson(record))
          .select()
          .single();
      return Right(MaintenanceRecordModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecord(String id) async {
    try {
      await _table.delete().eq('id', id);
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
