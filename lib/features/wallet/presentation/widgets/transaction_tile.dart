import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/wallet_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.txn});

  final WalletTransaction txn;

  IconData get _icon => switch (txn.kind) {
        WalletTxnKind.recharge => Icons.add_card_outlined,
        WalletTxnKind.purchase => Icons.shopping_bag_outlined,
        WalletTxnKind.cashback => Icons.savings_outlined,
        WalletTxnKind.withdrawal => Icons.south_west,
        WalletTxnKind.refund => Icons.undo,
      };

  @override
  Widget build(BuildContext context) {
    final color = txn.isCredit ? AppColors.success : AppColors.danger;
    final sign = txn.isCredit ? '+' : '−';
    final date = intl.DateFormat('yyyy/MM/dd  HH:mm').format(txn.createdAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(_icon, color: color, size: 20),
      ),
      title: Text(txn.kind.label,
          style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(PersianUtils.toFa(date),
          style: Theme.of(context).textTheme.labelSmall),
      trailing: Text(
        '$sign ${PersianUtils.formatToman(txn.amount.abs())}',
        style: TextStyle(
            color: color, fontWeight: FontWeight.w800, fontSize: 13),
      ),
    );
  }
}
