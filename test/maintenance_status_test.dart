import 'package:flutter_test/flutter_test.dart';
import 'package:motoverse/features/maintenance/domain/entities/maintenance_record.dart';
import 'package:motoverse/features/maintenance/domain/entities/maintenance_status.dart';
import 'package:motoverse/features/maintenance/domain/entities/maintenance_type.dart';

void main() {
  group('MaintenanceStatus', () {
    test('reports remaining km when service is in the future', () {
      final record = MaintenanceRecord(
        id: '1',
        motorcycleId: 'm1',
        type: MaintenanceType.engineOil,
        serviceDate: DateTime(2024),
        mileage: 10000,
        intervalKm: 2000,
      );
      final status = MaintenanceStatus(
        type: MaintenanceType.engineOil,
        currentMileage: 11000,
        lastRecord: record,
      );

      expect(status.dueAtMileage, 12000);
      expect(status.remainingKm, 1000);
      expect(status.isDue, isFalse);
      expect(status.urgency, MaintenanceUrgency.ok);
    });

    test('flags due when current mileage passes the interval', () {
      final record = MaintenanceRecord(
        id: '1',
        motorcycleId: 'm1',
        type: MaintenanceType.engineOil,
        serviceDate: DateTime(2024),
        mileage: 10000,
        intervalKm: 2000,
      );
      final status = MaintenanceStatus(
        type: MaintenanceType.engineOil,
        currentMileage: 12500,
        lastRecord: record,
      );

      expect(status.isDue, isTrue);
      expect(status.urgency, MaintenanceUrgency.due);
      expect(status.message, 'سرویس اکنون لازم است');
    });

    test('falls back to default interval when never serviced', () {
      final status = MaintenanceStatus(
        type: MaintenanceType.chainService,
        currentMileage: 5000,
      );
      // chainService default interval is 1000 km.
      expect(status.dueAtMileage, 6000);
      expect(status.remainingKm, 1000);
    });
  });
}
