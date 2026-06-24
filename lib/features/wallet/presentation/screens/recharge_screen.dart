import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/wallet_providers.dart';

class RechargeScreen extends ConsumerStatefulWidget {
  const RechargeScreen({super.key});

  @override
  ConsumerState<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends ConsumerState<RechargeScreen> {
  static const _presets = [100000, 200000, 500000, 1000000];
  int _amount = 200000;
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final custom = PersianUtils.toEn(_custom.text).replaceAll(RegExp(r'\D'), '');
    final amount = custom.isNotEmpty ? int.parse(custom) : _amount;
    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل مبلغ شارژ ۱۰,۰۰۰ تومان است')),
      );
      return;
    }

    final error =
        await ref.read(rechargeControllerProvider.notifier).recharge(amount);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('کیف پول با ${PersianUtils.formatToman(amount)} '
                'شارژ شد ✓')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gateway = ref.watch(paymentGatewayProvider);
    final loading = ref.watch(rechargeControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('شارژ کیف پول')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('مبلغ شارژ را انتخاب کنید',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: [
              for (final p in _presets)
                _AmountChip(
                  label: PersianUtils.formatToman(p),
                  selected: _custom.text.isEmpty && _amount == p,
                  onTap: () => setState(() {
                    _amount = p;
                    _custom.clear();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('یا مبلغ دلخواه (تومان)',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          TextField(
            controller: _custom,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'مثلاً ۳۵۰۰۰۰'),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('پرداخت امن از طریق ${gateway.displayName}',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'پرداخت و شارژ',
            gradient: true,
            isLoading: loading,
            onPressed: _pay,
          ),
        ],
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : null,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
