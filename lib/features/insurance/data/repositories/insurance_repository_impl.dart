import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/insurance_offer.dart';
import '../../domain/entities/insurance_policy.dart';
import '../../domain/repositories/insurance_repository.dart';
import '../datasources/insurance_offers_data.dart';
import '../models/insurance_policy_model.dart';

class InsuranceRepositoryImpl implements InsuranceRepository {
  InsuranceRepositoryImpl(this._client);

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<InsuranceOffer>>> getOffers(
    InsuranceKind kind,
  ) async {
    // Simulated aggregator latency.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Right(InsuranceOffersData.forKind(kind));
  }

  @override
  Future<Either<Failure, List<InsurancePolicy>>> getPolicies() async {
    try {
      final uid = _uid;
      if (uid == null) return const Left(AuthFailure());
      final rows = await _client
          .from(AppConstants.tInsurancePolicies)
          .select()
          .eq('owner_id', uid)
          .order('created_at', ascending: false);
      return Right(rows.map(InsurancePolicyModel.fromJson).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, InsurancePolicy>> buy({
    required String motorcycleId,
    required InsuranceOffer offer,
  }) async {
    try {
      final uid = _uid;
      if (uid == null) return const Left(AuthFailure());
      final now = DateTime.now();
      final row = await _client
          .from(AppConstants.tInsurancePolicies)
          .insert({
            'motorcycle_id': motorcycleId,
            'owner_id': uid,
            'kind': offer.kind.key,
            'provider': offer.provider,
            'premium': offer.premium,
            'start_date': now.toIso8601String(),
            'end_date': now.add(const Duration(days: 365)).toIso8601String(),
            'status': 'pending',
          })
          .select()
          .single();
      return Right(InsurancePolicyModel.fromJson(row));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
