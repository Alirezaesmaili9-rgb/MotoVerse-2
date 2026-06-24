import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// DI: bind the Supabase-backed implementation to the [AuthRepository] port.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Current app user, derived from auth state. Refetches the profile whenever
/// the Supabase auth session changes.
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  // Re-run when auth state changes.
  ref.watch(authStateChangesProvider);
  final result = await ref.watch(authRepositoryProvider).currentUser();
  return result.fold((_) => null, (user) => user);
});

/// Drives OTP request + verification UI.
final otpControllerProvider =
    AsyncNotifierProvider<OtpController, OtpStage>(OtpController.new);

enum OtpStage { idle, codeSent, verified }

class OtpController extends AsyncNotifier<OtpStage> {
  String? _phone;

  @override
  OtpStage build() => OtpStage.idle;

  String? get phone => _phone;

  Future<void> sendOtp(String phone) async {
    _phone = phone;
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).sendOtp(phone);
    state = result.fold(
      (f) => AsyncValue.error(f.message, StackTrace.current),
      (_) => const AsyncValue.data(OtpStage.codeSent),
    );
  }

  Future<void> verify(String token) async {
    final phone = _phone;
    if (phone == null) return;
    state = const AsyncValue.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .verifyOtp(phone: phone, token: token);
    state = result.fold(
      (f) => AsyncValue.error(f.message, StackTrace.current),
      (_) {
        ref.invalidate(appUserProvider);
        return const AsyncValue.data(OtpStage.verified);
      },
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidate(appUserProvider);
    _phone = null;
    state = const AsyncValue.data(OtpStage.idle);
  }
}
