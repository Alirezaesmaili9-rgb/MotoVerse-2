import 'package:equatable/equatable.dart';

/// Kinds of wallet movements (mirrors the `wallet_transactions.kind` check).
enum WalletTxnKind {
  recharge('شارژ کیف پول'),
  purchase('خرید از مارکت‌پلیس'),
  cashback('بازگشت وجه'),
  withdrawal('برداشت'),
  refund('استرداد وجه');

  const WalletTxnKind(this.label);
  final String label;

  static WalletTxnKind fromKey(String key) => values.firstWhere(
        (k) => k.name == key,
        orElse: () => WalletTxnKind.purchase,
      );
}

class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.amount, // +credit / -debit (Toman)
    required this.kind,
    required this.createdAt,
    this.reference,
  });

  final String id;
  final int amount;
  final WalletTxnKind kind;
  final DateTime createdAt;
  final String? reference;

  bool get isCredit => amount >= 0;

  @override
  List<Object?> get props => [id, amount, kind, createdAt, reference];
}
