import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/garage_repository_impl.dart';
import '../../domain/entities/motorcycle.dart';
import '../../domain/repositories/garage_repository.dart';

final garageRepositoryProvider = Provider<GarageRepository>((ref) {
  return GarageRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// All motorcycles in the signed-in user's garage.
final motorcyclesProvider =
    AsyncNotifierProvider<MotorcyclesNotifier, List<Motorcycle>>(
  MotorcyclesNotifier.new,
);

class MotorcyclesNotifier extends AsyncNotifier<List<Motorcycle>> {
  GarageRepository get _repo => ref.read(garageRepositoryProvider);

  @override
  Future<List<Motorcycle>> build() async {
    // Rebuild when auth changes.
    ref.watch(authStateChangesProvider);
    final result = await _repo.getMotorcycles();
    return result.fold((f) => throw Exception(f.message), (bikes) => bikes);
  }

  Future<void> add(Motorcycle bike) async {
    final result = await _repo.addMotorcycle(bike);
    result.fold((_) {}, (_) => ref.invalidateSelf());
    await future;
  }

  Future<void> update(Motorcycle bike) async {
    final result = await _repo.updateMotorcycle(bike);
    result.fold((_) {}, (_) => ref.invalidateSelf());
    await future;
  }

  Future<void> remove(String id) async {
    await _repo.deleteMotorcycle(id);
    ref.invalidateSelf();
    await future;
  }
}

/// The user's primary motorcycle (first one flagged primary, else first).
final primaryMotorcycleProvider = Provider<Motorcycle?>((ref) {
  final bikes = ref.watch(motorcyclesProvider).valueOrNull ?? const [];
  if (bikes.isEmpty) return null;
  return bikes.firstWhere((b) => b.isPrimary, orElse: () => bikes.first);
});
