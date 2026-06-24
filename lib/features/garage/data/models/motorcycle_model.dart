import '../../domain/entities/motorcycle.dart';

/// (De)serializes [Motorcycle] to/from the `motorcycles` table.
class MotorcycleModel {
  const MotorcycleModel._();

  static Motorcycle fromJson(Map<String, dynamic> json) {
    return Motorcycle(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      productionYear: (json['production_year'] as num?)?.toInt(),
      engineCc: (json['engine_cc'] as num?)?.toInt(),
      mileage: (json['mileage'] as num?)?.toInt() ?? 0,
      plateTop: json['plate_top'] as String?,
      plateBottom: json['plate_bottom'] as String?,
      chassisNumber: json['chassis_number'] as String?,
      engineNumber: json['engine_number'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Payload for insert/update. `id` is omitted on insert so Postgres
  /// generates the UUID.
  static Map<String, dynamic> toJson(Motorcycle bike, {bool includeId = false}) {
    return {
      if (includeId) 'id': bike.id,
      'owner_id': bike.ownerId,
      'brand': bike.brand,
      'model': bike.model,
      'production_year': bike.productionYear,
      'engine_cc': bike.engineCc,
      'mileage': bike.mileage,
      'plate_top': bike.plateTop,
      'plate_bottom': bike.plateBottom,
      'chassis_number': bike.chassisNumber,
      'engine_number': bike.engineNumber,
      'is_primary': bike.isPrimary,
      'notes': bike.notes,
    };
  }
}
