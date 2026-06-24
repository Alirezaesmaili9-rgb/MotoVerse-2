import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<Either<Failure, Unit>> sendOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
      return const Right(unit);
    } on sb.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final res = await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: sb.OtpType.sms,
      );
      final user = res.user;
      if (user == null) return const Left(AuthFailure('کد تأیید نامعتبر است'));
      return Right(await _loadProfile(user));
    } on sb.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() =>
      _oauth(sb.OAuthProvider.google);

  @override
  Future<Either<Failure, AppUser>> signInWithApple() =>
      _oauth(sb.OAuthProvider.apple);

  Future<Either<Failure, AppUser>> _oauth(sb.OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(provider);
      // The session resolves via the auth state stream after the redirect.
      final user = _client.auth.currentUser;
      if (user == null) return const Left(AuthFailure());
      return Right(await _loadProfile(user));
    } on sb.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AppUser?>> currentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const Right(null);
      return Right(await _loadProfile(user));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  /// Loads the matching `profiles` row, creating it on first sign-in.
  Future<AppUser> _loadProfile(sb.User user) async {
    final existing = await _client
        .from(AppConstants.tProfiles)
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await _client
          .from(AppConstants.tProfiles)
          .insert(AppUserModel.toProfileInsert(user));
      return AppUserModel.fromSupabase(user);
    }
    return AppUserModel.fromSupabase(user, profile: existing);
  }
}
