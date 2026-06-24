import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/insurance_offer.dart';
import '../entities/insurance_policy.dart';

abstract interface class InsuranceRepository {
  /// Comparable quotes for a given [kind] (sorted cheapest first).
  Future<Either<Failure, List<InsuranceOffer>>> getOffers(InsuranceKind kind);

  /// The signed-in user's policies (across their motorcycles).
  Future<Either<Failure, List<InsurancePolicy>>> getPolicies();

  /// Purchases an offer for a motorcycle; creates a pending policy.
  Future<Either<Failure, InsurancePolicy>> buy({
    required String motorcycleId,
    required InsuranceOffer offer,
  });
}
