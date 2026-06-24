import '../../domain/entities/service_booking.dart';
import '../../domain/entities/service_center.dart';

class ServiceCenterModel {
  const ServiceCenterModel._();

  static ServiceCenter fromJson(Map<String, dynamic> json) {
    return ServiceCenter(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      brands: (json['brands'] as List?)?.cast<String>() ?? const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      phone: json['phone'] as String?,
    );
  }
}

class ServiceBookingModel {
  const ServiceBookingModel._();

  static ServiceBooking fromJson(Map<String, dynamic> json) {
    final center = json['service_centers'] as Map<String, dynamic>?;
    return ServiceBooking(
      id: json['id'] as String,
      serviceCenterId: json['service_center_id'] as String,
      status: BookingStatus.fromKey(json['status'] as String),
      centerName: center?['name'] as String?,
      motorcycleId: json['motorcycle_id'] as String?,
      scheduledAt: json['scheduled_at'] == null
          ? null
          : DateTime.parse(json['scheduled_at'] as String),
      notes: json['notes'] as String?,
    );
  }
}
