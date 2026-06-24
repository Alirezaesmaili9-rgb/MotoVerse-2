import '../../../garage/domain/entities/motorcycle.dart';

/// The data the app injects into an embedded tool as `window.MotoVerseContext`.
///
/// This is the **app → tool** half of the bridge: it lets a tool pre-fill the
/// user's motorcycle without the app modifying the tool's internal logic.
class ToolContext {
  const ToolContext({
    this.brand,
    this.model,
    this.productionYear,
    this.engineCc,
    this.mileage,
    this.locale = 'fa',
  });

  final String? brand;
  final String? model;
  final int? productionYear;
  final int? engineCc;
  final int? mileage;
  final String locale;

  factory ToolContext.fromMotorcycle(Motorcycle? bike) {
    if (bike == null) return const ToolContext();
    return ToolContext(
      brand: bike.brand,
      model: bike.model,
      productionYear: bike.productionYear,
      engineCc: bike.engineCc,
      mileage: bike.mileage,
    );
  }

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        'year': productionYear,
        'engineCc': engineCc,
        'mileage': mileage,
        'locale': locale,
        'app': 'MotoVerse',
      };
}
