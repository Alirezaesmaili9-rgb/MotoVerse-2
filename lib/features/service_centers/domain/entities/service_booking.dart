import 'package:equatable/equatable.dart';

enum BookingStatus {
  requested('در انتظار تأیید'),
  confirmed('تأیید شده'),
  done('انجام شده'),
  cancelled('لغو شده');

  const BookingStatus(this.label);
  final String label;

  static BookingStatus fromKey(String key) => switch (key) {
        'confirmed' => BookingStatus.confirmed,
        'done' => BookingStatus.done,
        'cancelled' => BookingStatus.cancelled,
        _ => BookingStatus.requested,
      };
}

class ServiceBooking extends Equatable {
  const ServiceBooking({
    required this.id,
    required this.serviceCenterId,
    required this.status,
    this.centerName,
    this.motorcycleId,
    this.scheduledAt,
    this.notes,
  });

  final String id;
  final String serviceCenterId;
  final BookingStatus status;
  final String? centerName;
  final String? motorcycleId;
  final DateTime? scheduledAt;
  final String? notes;

  @override
  List<Object?> get props => [id, serviceCenterId, status, scheduledAt];
}
