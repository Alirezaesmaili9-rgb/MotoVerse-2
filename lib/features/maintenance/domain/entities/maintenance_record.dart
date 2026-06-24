import 'package:equatable/equatable.dart';

import 'maintenance_type.dart';

/// A single logged maintenance event for a motorcycle.
class MaintenanceRecord extends Equatable {
  const MaintenanceRecord({
    required this.id,
    required this.motorcycleId,
    required this.type,
    required this.serviceDate,
    required this.mileage,
    required this.intervalKm,
    this.cost,
    this.serviceCenter,
    this.notes,
  });

  final String id;
  final String motorcycleId;
  final MaintenanceType type;
  final DateTime serviceDate;
  final int mileage;
  final int intervalKm;
  final int? cost; // Toman
  final String? serviceCenter;
  final String? notes;

  /// The odometer reading at which the next service of this type is due.
  int get nextServiceMileage => mileage + intervalKm;

  @override
  List<Object?> get props => [
        id,
        motorcycleId,
        type,
        serviceDate,
        mileage,
        intervalKm,
        cost,
        serviceCenter,
        notes,
      ];
}
