import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel {
  const WalletTransactionModel._();

  static WalletTransaction fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      kind: WalletTxnKind.fromKey(json['kind'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      reference: json['reference'] as String?,
    );
  }
}
