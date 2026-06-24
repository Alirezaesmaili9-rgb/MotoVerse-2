import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/insurance_repository_impl.dart';
import '../../domain/entities/insurance_offer.dart';
import '../../domain/entities/insurance_policy.dart';
import '../../domain/repositories/insurance_repository.dart';

final insuranceRepositoryProvider = Provider<InsuranceRepository>((ref) {
  return InsuranceRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Currently selected insurance kind on the comparison screen.
final selectedInsuranceKindProvider =
    StateProvider<InsuranceKind>((ref) => InsuranceKind.thirdParty);

/// Offers for the selected kind.
final insuranceOffersProvider =
    FutureProvider.autoDispose<List<InsuranceOffer>>((ref) async {
  final kind = ref.watch(selectedInsuranceKindProvider);
  final res = await ref.watch(insuranceRepositoryProvider).getOffers(kind);
  return res.fold((f) => throw Exception(f.message), (o) => o);
});

/// The user's purchased policies.
final policiesProvider =
    FutureProvider.autoDispose<List<InsurancePolicy>>((ref) async {
  ref.watch(authStateChangesProvider);
  final res = await ref.watch(insuranceRepositoryProvider).getPolicies();
  return res.fold((f) => throw Exception(f.message), (p) => p);
});

/// Purchases an offer; returns null on success or an error message.
final buyInsuranceProvider = Provider((ref) => _BuyInsurance(ref));

class _BuyInsurance {
  _BuyInsurance(this.ref);
  final Ref ref;

  Future<String?> call({
    required String motorcycleId,
    required InsuranceOffer offer,
  }) async {
    final res = await ref
        .read(insuranceRepositoryProvider)
        .buy(motorcycleId: motorcycleId, offer: offer);
    return res.fold((f) => f.message, (_) {
      ref.invalidate(policiesProvider);
      return null;
    });
  }
}
