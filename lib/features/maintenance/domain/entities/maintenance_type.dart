/// The maintenance items MotoVerse tracks, each with a sensible default
/// service interval (km) tuned for the Iranian small-displacement market.
enum MaintenanceType {
  engineOil('روغن موتور', 2000),
  gearOil('روغن واسکازین', 6000),
  airFilter('فیلتر هوا', 8000),
  sparkPlug('شمع', 8000),
  chainService('سرویس زنجیر', 1000),
  brakePads('لنت ترمز', 10000),
  tires('تایر', 15000),
  coolant('مایع خنک‌کننده', 12000),
  battery('باتری', 20000);

  const MaintenanceType(this.label, this.defaultIntervalKm);

  /// Persian display label.
  final String label;

  /// Recommended distance between services, in kilometres.
  final int defaultIntervalKm;

  static MaintenanceType fromKey(String key) =>
      MaintenanceType.values.firstWhere(
        (t) => t.name == key,
        orElse: () => MaintenanceType.engineOil,
      );
}
