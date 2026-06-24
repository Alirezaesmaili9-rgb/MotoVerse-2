import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../wallet/presentation/providers/wallet_providers.dart';
import '../providers/cart_providers.dart';

/// Checkout: review totals, confirm wallet payment (2% cashback), place order.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _placing = false;

  Future<void> _placeOrder(int total, int balance) async {
    if (balance < total) {
      final go = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('موجودی ناکافی'),
          content: const Text('موجودی کیف پول برای این خرید کافی نیست. '
              'ابتدا کیف پول را شارژ کنید.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('بعداً')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('شارژ کیف پول')),
          ],
        ),
      );
      if (go == true && mounted) context.push(AppRoutes.walletRecharge);
      return;
    }

    setState(() => _placing = true);
    final error = await ref.read(cartProvider.notifier).checkout();
    if (!mounted) return;
    setState(() => _placing = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      context.go(AppRoutes.orders);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سفارش شما با موفقیت ثبت شد ✓')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);
    final balance = ref.watch(walletBalanceProvider).valueOrNull ?? 0;
    final cashback = (total * 0.02).floor();

    return Scaffold(
      appBar: AppBar(title: const Text('تسویه حساب')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(
            children: [
              _row(context, 'مبلغ سفارش', PersianUtils.formatToman(total)),
              _row(context, 'هزینه ارسال', 'رایگان', valueColor: AppColors.success),
              _row(context, 'بازگشت وجه (۲٪)',
                  '+ ${PersianUtils.formatToman(cashback)}',
                  valueColor: AppColors.success),
              const Divider(height: 24),
              _row(context, 'مبلغ قابل پرداخت',
                  PersianUtils.formatToman(total),
                  bold: true),
            ],
          ),
          const SizedBox(height: 16),
          Text('روش پرداخت', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('کیف پول MotoVerse',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text('موجودی: ${PersianUtils.formatToman(balance)}',
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            label: 'پرداخت ${PersianUtils.formatToman(total)}',
            gradient: true,
            isLoading: _placing,
            onPressed: () => _placeOrder(total, balance),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool bold = false, Color? valueColor}) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style?.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}
