import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/service_booking.dart';
import '../entities/service_center.dart';

abstract interface class ServiceCentersRepository {
  Future<Either<Failure, List<ServiceCenter>>> getCenters({String? query});

  Future<Either<Failure, List<ServiceBooking>>> getBookings();

  Future<Either<Failure, ServiceBooking>> book({
    required String serviceCenterId,
    String? motorcycleId,
    DateTime? scheduledAt,
    String? notes,
  });
}
