import 'package:equatable/equatable.dart';

/// A motorcycle registered in the user's garage. Users can own several.
class Motorcycle extends Equatable {
  const Motorcycle({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    this.productionYear,
    this.engineCc,
    this.mileage = 0,
    this.plateTop,
    this.plateBottom,
    this.chassisNumber,
    this.engineNumber,
    this.isPrimary = false,
    this.notes,
  });

  final String id;
  final String ownerId;
  final String brand;
  final String model;
  final int? productionYear;
  final int? engineCc;
  final int mileage;

  /// Iranian plate split: 3-digit top, 5-digit bottom (Persian digits stored).
  final String? plateTop;
  final String? plateBottom;

  final String? chassisNumber;
  final String? engineNumber;
  final bool isPrimary;
  final String? notes;

  String get displayName => '$brand $model';

  Motorcycle copyWith({
    String? brand,
    String? model,
    int? productionYear,
    int? engineCc,
    int? mileage,
    String? plateTop,
    String? plateBottom,
    String? chassisNumber,
    String? engineNumber,
    bool? isPrimary,
    String? notes,
  }) {
    return Motorcycle(
      id: id,
      ownerId: ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      productionYear: productionYear ?? this.productionYear,
      engineCc: engineCc ?? this.engineCc,
      mileage: mileage ?? this.mileage,
      plateTop: plateTop ?? this.plateTop,
      plateBottom: plateBottom ?? this.plateBottom,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      isPrimary: isPrimary ?? this.isPrimary,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        brand,
        model,
        productionYear,
        engineCc,
        mileage,
        plateTop,
        plateBottom,
        chassisNumber,
        engineNumber,
        isPrimary,
        notes,
      ];
}
