import '../../domain/entities/roadside_request.dart';

class RoadsideRequestModel {
  const RoadsideRequestModel._();

  static RoadsideRequest fromJson(Map<String, dynamic> json) {
    return RoadsideRequest(
      id: json['id'] as String,
      kind: RoadsideKind.fromKey(json['kind'] as String),
      status: RoadsideStatus.fromKey(json['status'] as String),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      technicianId: json['technician_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
