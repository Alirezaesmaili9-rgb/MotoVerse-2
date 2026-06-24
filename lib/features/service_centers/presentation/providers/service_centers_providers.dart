import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/service_centers_repository_impl.dart';
import '../../domain/entities/service_booking.dart';
import '../../domain/entities/service_center.dart';
import '../../domain/repositories/service_centers_repository.dart';

final serviceCentersRepositoryProvider =
    Provider<ServiceCentersRepository>((ref) {
  return ServiceCentersRepositoryImpl(ref.watch(supabaseClientProvider));
});

final centersSearchProvider = StateProvider<String>((ref) => '');

final serviceCentersProvider =
    FutureProvider.autoDispose<List<ServiceCenter>>((ref) async {
  final query = ref.watch(centersSearchProvider);
  final res = await ref
      .watch(serviceCentersRepositoryProvider)
      .getCenters(query: query);
  return res.fold((f) => throw Exception(f.message), (c) => c);
});

final bookingsProvider =
    FutureProvider.autoDispose<List<ServiceBooking>>((ref) async {
  ref.watch(authStateChangesProvider);
  final res = await ref.watch(serviceCentersRepositoryProvider).getBookings();
  return res.fold((f) => throw Exception(f.message), (b) => b);
});

final bookServiceProvider = Provider((ref) => _BookService(ref));

class _BookService {
  _BookService(this.ref);
  final Ref ref;

  Future<String?> call({
    required String serviceCenterId,
    String? motorcycleId,
    DateTime? scheduledAt,
    String? notes,
  }) async {
    final res = await ref.read(serviceCentersRepositoryProvider).book(
          serviceCenterId: serviceCenterId,
          motorcycleId: motorcycleId,
          scheduledAt: scheduledAt,
          notes: notes,
        );
    return res.fold((f) => f.message, (_) {
      ref.invalidate(bookingsProvider);
      return null;
    });
  }
}
