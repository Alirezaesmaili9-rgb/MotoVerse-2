import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/roadside_request.dart';

abstract interface class RoadsideRepository {
  Future<Either<Failure, RoadsideRequest>> createRequest({
    required RoadsideKind kind,
    double? lat,
    double? lng,
  });

  Future<Either<Failure, List<RoadsideRequest>>> getHistory();

  Future<Either<Failure, Unit>> cancel(String id);

  /// Live updates (status / ETA / technician) for a request via Supabase
  /// realtime — powers the tracking screen.
  Stream<RoadsideRequest> watch(String id);
}
