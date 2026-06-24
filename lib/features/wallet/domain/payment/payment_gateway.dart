/// Modular payment abstraction.
///
/// MotoVerse keeps payment provider-agnostic: the wallet recharge flow depends
/// only on this interface. Swap in Zarinpal / IDPay / a PSP by providing a new
/// [PaymentGateway] implementation and overriding `paymentGatewayProvider` —
/// no UI or repository changes required.
abstract interface class PaymentGateway {
  /// Human-readable name (shown on the recharge screen).
  String get displayName;

  /// Begins a payment for [amount] Toman. Returns the settled [PaymentResult].
  /// In a real gateway this opens a redirect/WebView and resolves on callback.
  Future<PaymentResult> pay({
    required int amount,
    String? description,
  });
}

enum PaymentStatus { success, failed, cancelled }

class PaymentResult {
  const PaymentResult({
    required this.status,
    required this.amount,
    this.referenceId,
    this.message,
  });

  final PaymentStatus status;
  final int amount;

  /// Gateway transaction/reference id, stored against the wallet recharge.
  final String? referenceId;
  final String? message;

  bool get isSuccess => status == PaymentStatus.success;
}
