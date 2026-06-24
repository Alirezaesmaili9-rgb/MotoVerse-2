import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/maintenance_record.dart';

abstract interface class MaintenanceRepository {
  /// All maintenance records for a motorcycle, newest first.
  Future<Either<Failure, List<MaintenanceRecord>>> getRecords(
    String motorcycleId,
  );

  Future<Either<Failure, MaintenanceRecord>> addRecord(MaintenanceRecord record);

  Future<Either<Failure, Unit>> deleteRecord(String id);
}
