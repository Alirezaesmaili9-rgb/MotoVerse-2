import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/motorcycle.dart';

abstract interface class GarageRepository {
  Future<Either<Failure, List<Motorcycle>>> getMotorcycles();

  Future<Either<Failure, Motorcycle>> addMotorcycle(Motorcycle bike);

  Future<Either<Failure, Motorcycle>> updateMotorcycle(Motorcycle bike);

  Future<Either<Failure, Unit>> deleteMotorcycle(String id);

  /// Updates only the odometer reading (called after a maintenance log).
  Future<Either<Failure, Unit>> updateMileage(String id, int mileage);
}
