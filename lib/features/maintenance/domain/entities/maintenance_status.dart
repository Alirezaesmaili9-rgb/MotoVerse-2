import 'maintenance_record.dart';
import 'maintenance_type.dart';

/// Urgency level for a maintenance item. Drives badge color only — never a
/// numeric "health score" (explicitly forbidden by the spec).
enum MaintenanceUrgency { ok, soon, due }

/// Per-type maintenance status, computed from the latest record and the
/// motorcycle's current mileage. The app surfaces *actionable* information:
/// "Service due in X km" or "Service is now due" — no health percentages.
class MaintenanceStatus {
  const MaintenanceStatus({
    required this.type,
    required this.currentMileage,
    this.lastRecord,
  });

  final MaintenanceType type;
  final int currentMileage;
  final MaintenanceRecord? lastRecord;

  /// Odometer at which this service is next due. If never serviced, we assume
  /// it's due from the current reading using the default interval.
  int get dueAtMileage =>
      lastRecord?.nextServiceMileage ?? currentMileage + type.defaultIntervalKm;

  /// Remaining distance until due. Negative means overdue.
  int get remainingKm => dueAtMileage - currentMileage;

  bool get isDue => remainingKm <= 0;

  MaintenanceUrgency get urgency {
    if (isDue) return MaintenanceUrgency.due;
    final interval = lastRecord?.intervalKm ?? type.defaultIntervalKm;
    // Within the last 15% of the interval → "soon".
    if (remainingKm <= interval * 0.15) return MaintenanceUrgency.soon;
    return MaintenanceUrgency.ok;
  }

  /// Persian, actionable summary line.
  String get message {
    if (isDue) return 'سرویس اکنون لازم است';
    return 'سرویس تا ${remainingKm.toString()} کیلومتر دیگر';
  }
}
