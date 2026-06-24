import 'package:equatable/equatable.dart';

/// Roadside assistance service types.
enum RoadsideKind {
  tire('پنچرگیری', '🛞'),
  battery('باتری به باتری', '🔋'),
  fuel('رساندن سوخت', '⛽'),
  towing('حمل موتور', '🚚'),
  mechanical('تعمیر در محل', '🔧');

  const RoadsideKind(this.label, this.emoji);
  final String label;
  final String emoji;

  static RoadsideKind fromKey(String key) => values.firstWhere(
        (k) => k.name == key,
        orElse: () => RoadsideKind.mechanical,
      );
}

/// Request lifecycle, mirroring the `roadside_requests.status` check.
enum RoadsideStatus {
  requested('در حال یافتن امدادگر', 0),
  assigned('امدادگر اختصاص یافت', 1),
  enroute('امدادگر در راه است', 2),
  done('انجام شد', 3),
  cancelled('لغو شده', -1);

  const RoadsideStatus(this.label, this.step);
  final String label;
  final int step;

  static RoadsideStatus fromKey(String key) => values.firstWhere(
        (s) => s.name == key,
        orElse: () => RoadsideStatus.requested,
      );

  bool get isActive => this == requested || this == assigned || this == enroute;
}

class RoadsideRequest extends Equatable {
  const RoadsideRequest({
    required this.id,
    required this.kind,
    required this.status,
    this.lat,
    this.lng,
    this.etaMinutes,
    this.technicianId,
    required this.createdAt,
  });

  final String id;
  final RoadsideKind kind;
  final RoadsideStatus status;
  final double? lat;
  final double? lng;
  final int? etaMinutes;
  final String? technicianId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, kind, status, etaMinutes, technicianId];
}
