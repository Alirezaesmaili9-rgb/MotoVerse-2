import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../garage/presentation/providers/garage_providers.dart';
import '../../data/repositories/maintenance_repository_impl.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/entities/maintenance_status.dart';
import '../../domain/entities/maintenance_type.dart';
import '../../domain/repositories/maintenance_repository.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return MaintenanceRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Add / delete maintenance records and keep the motorcycle's odometer in sync.
final maintenanceActionsProvider = Provider((ref) => MaintenanceActions(ref));

class MaintenanceActions {
  MaintenanceActions(this.ref);
  final Ref ref;

  /// Logs a record; if [newMileage] exceeds the bike's reading, the odometer
  /// is bumped so future "service due in X km" calculations stay accurate.
  Future<String?> addRecord(MaintenanceRecord record, {int? newMileage}) async {
    final res = await ref.read(maintenanceRepositoryProvider).addRecord(record);
    return res.fold((f) => f.message, (_) {
      if (newMileage != null && newMileage > 0) {
        ref
            .read(garageRepositoryProvider)
            .updateMileage(record.motorcycleId, newMileage);
        ref.invalidate(motorcyclesProvider);
      }
      ref.invalidate(maintenanceRecordsProvider(record.motorcycleId));
      return null;
    });
  }

  Future<void> deleteRecord(String id, String motorcycleId) async {
    await ref.read(maintenanceRepositoryProvider).deleteRecord(id);
    ref.invalidate(maintenanceRecordsProvider(motorcycleId));
  }
}

/// Maintenance records for a given motorcycle.
final maintenanceRecordsProvider = FutureProvider.family<
    List<MaintenanceRecord>, String>((ref, motorcycleId) async {
  final result =
      await ref.watch(maintenanceRepositoryProvider).getRecords(motorcycleId);
  return result.fold((f) => throw Exception(f.message), (r) => r);
});

/// Computed [MaintenanceStatus] per type for the primary motorcycle — drives
/// the home-screen "service due in X km" reminders.
final maintenanceStatusesProvider =
    Provider<List<MaintenanceStatus>>((ref) {
  final bike = ref.watch(primaryMotorcycleProvider);
  if (bike == null) return const [];

  final records =
      ref.watch(maintenanceRecordsProvider(bike.id)).valueOrNull ?? const [];

  return MaintenanceType.values.map((type) {
    // Latest record of this type = highest mileage (records are desc).
    MaintenanceRecord? last;
    for (final r in records) {
      if (r.type == type) {
        last = r;
        break;
      }
    }
    return MaintenanceStatus(
      type: type,
      currentMileage: bike.mileage,
      lastRecord: last,
    );
  }).toList();
});

/// The single most urgent item, for the home "next maintenance" card.
final nextMaintenanceProvider = Provider<MaintenanceStatus?>((ref) {
  final statuses = ref.watch(maintenanceStatusesProvider);
  if (statuses.isEmpty) return null;
  final sorted = [...statuses]
    ..sort((a, b) => a.remainingKm.compareTo(b.remainingKm));
  return sorted.first;
});
