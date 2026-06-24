import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/payment/sandbox_payment_gateway.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/payment/payment_gateway.dart';
import '../../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Swappable payment provider. Override this to plug in a real PSP.
final paymentGatewayProvider = Provider<PaymentGateway>((ref) {
  return const SandboxPaymentGateway();
});

/// Current wallet balance (Toman).
final walletBalanceProvider = FutureProvider<int>((ref) async {
  ref.watch(authStateChangesProvider);
  final res = await ref.watch(walletRepositoryProvider).getBalance();
  return res.fold((_) => 0, (b) => b);
});

/// Wallet transaction history.
final walletTransactionsProvider =
    FutureProvider<List<WalletTransaction>>((ref) async {
  ref.watch(authStateChangesProvider);
  final res = await ref.watch(walletRepositoryProvider).getTransactions();
  return res.fold((f) => throw Exception(f.message), (t) => t);
});

/// Drives the recharge flow: gateway payment → server credit.
final rechargeControllerProvider =
    AsyncNotifierProvider<RechargeController, void>(RechargeController.new);

class RechargeController extends AsyncNotifier<void> {
  @override
  void build() {}

  /// Runs payment then credits the wallet. Returns null on success or an
  /// error message on failure.
  Future<String?> recharge(int amount) async {
    state = const AsyncValue.loading();

    final payment =
        await ref.read(paymentGatewayProvider).pay(amount: amount);
    if (!payment.isSuccess) {
      state = const AsyncValue.data(null);
      return payment.message ?? 'پرداخت ناموفق بود';
    }

    final res = await ref.read(walletRepositoryProvider).recharge(
          amount: amount,
          reference: payment.referenceId,
        );

    return res.fold(
      (f) {
        state = AsyncValue.error(f.message, StackTrace.current);
        return f.message;
      },
      (_) {
        ref.invalidate(walletBalanceProvider);
        ref.invalidate(walletTransactionsProvider);
        ref.invalidate(appUserProvider);
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }
}
