import 'package:equatable/equatable.dart';

/// Domain representation of an authenticated MotoVerse user / profile.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    this.phone,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.walletBalance = 0,
  });

  final String id;
  final String? phone;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final int walletBalance; // Toman

  AppUser copyWith({
    String? fullName,
    String? avatarUrl,
    int? walletBalance,
  }) {
    return AppUser(
      id: id,
      phone: phone,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props =>
      [id, phone, email, fullName, avatarUrl, walletBalance];
}
