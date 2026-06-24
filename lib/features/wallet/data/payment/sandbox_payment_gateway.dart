import 'dart:math';

import '../../domain/payment/payment_gateway.dart';

/// Default sandbox gateway used until a real PSP is wired in.
///
/// Simulates a gateway round-trip and always succeeds, returning a synthetic
/// reference id. Replace by overriding `paymentGatewayProvider` with a real
/// implementation (Zarinpal, IDPay, ...) — nothing else changes.
class SandboxPaymentGateway implements PaymentGateway {
  const SandboxPaymentGateway();

  @override
  String get displayName => 'درگاه آزمایشی MotoVerse';

  @override
  Future<PaymentResult> pay({
    required int amount,
    String? description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final ref = 'MV-${DateTime.now().millisecondsSinceEpoch}-'
        '${Random().nextInt(9999).toString().padLeft(4, '0')}';
    return PaymentResult(
      status: PaymentStatus.success,
      amount: amount,
      referenceId: ref,
      message: 'پرداخت با موفقیت انجام شد',
    );
  }
}
