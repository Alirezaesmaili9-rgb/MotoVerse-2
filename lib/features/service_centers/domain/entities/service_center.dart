import 'package:equatable/equatable.dart';

/// A repair shop / dealership in the public catalog.
class ServiceCenter extends Equatable {
  const ServiceCenter({
    required this.id,
    required this.name,
    this.address,
    this.lat,
    this.lng,
    this.brands = const [],
    this.rating = 0,
    this.phone,
  });

  final String id;
  final String name;
  final String? address;
  final double? lat;
  final double? lng;
  final List<String> brands;
  final double rating;
  final String? phone;

  bool get hasLocation => lat != null && lng != null;

  @override
  List<Object?> get props => [id, name, address, lat, lng, rating];
}
