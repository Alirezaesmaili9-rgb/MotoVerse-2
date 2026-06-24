import 'package:equatable/equatable.dart';

/// A user row as seen by the admin (read across all profiles via is_admin()).
class AdminUser extends Equatable {
  const AdminUser({
    required this.id,
    required this.role,
    this.fullName,
    this.phone,
    this.walletBalance = 0,
    this.createdAt,
  });

  final String id;
  final String role;
  final String? fullName;
  final String? phone;
  final int walletBalance;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, role, fullName, phone, walletBalance];
}
