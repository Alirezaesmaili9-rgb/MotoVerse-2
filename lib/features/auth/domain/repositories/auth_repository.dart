import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

/// Authentication contract. Implemented in the data layer against Supabase.
/// Supports Phone OTP, Google, and Apple sign-in per the spec.
abstract interface class AuthRepository {
  /// Sends a one-time password to [phone] (E.164, e.g. +98912...).
  Future<Either<Failure, Unit>> sendOtp(String phone);

  /// Verifies the [token] sent to [phone] and signs the user in.
  Future<Either<Failure, AppUser>> verifyOtp({
    required String phone,
    required String token,
  });

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, AppUser>> signInWithApple();

  Future<Either<Failure, Unit>> signOut();

  /// The currently signed-in user's profile, or null.
  Future<Either<Failure, AppUser?>> currentUser();
}
