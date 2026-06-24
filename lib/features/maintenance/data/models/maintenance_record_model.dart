import '../../domain/entities/maintenance_record.dart';
import '../../domain/entities/maintenance_type.dart';

class MaintenanceRecordModel {
  const MaintenanceRecordModel._();

  static MaintenanceRecord fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'] as String,
      motorcycleId: json['motorcycle_id'] as String,
      type: MaintenanceType.fromKey(json['type'] as String),
      serviceDate: DateTime.parse(json['service_date'] as String),
      mileage: (json['mileage'] as num).toInt(),
      intervalKm: (json['interval_km'] as num).toInt(),
      cost: (json['cost'] as num?)?.toInt(),
      serviceCenter: json['service_center'] as String?,
      notes: json['notes'] as String?,
    );
  }

  static Map<String, dynamic> toJson(MaintenanceRecord r) => {
        'motorcycle_id': r.motorcycleId,
        'type': r.type.name,
        'service_date': r.serviceDate.toIso8601String(),
        'mileage': r.mileage,
        'interval_km': r.intervalKm,
        'cost': r.cost,
        'service_center': r.serviceCenter,
        'notes': r.notes,
      };
}
