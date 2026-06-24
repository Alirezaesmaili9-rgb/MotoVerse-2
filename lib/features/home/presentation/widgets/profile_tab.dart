import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../admin/presentation/providers/admin_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../wallet/presentation/providers/wallet_providers.dart';

/// Profile tab: identity header, wallet shortcut, and links to orders,
/// favorites, and transactions.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;
    final balance = ref.watch(walletBalanceProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل من')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                child: const Text('🏍', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.fullName ?? 'موتورسوار',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(user?.phone ?? 'شماره ثبت نشده',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Wallet shortcut
          InkWell(
            onTap: () => context.push(AppRoutes.wallet),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('کیف پول',
                          style: TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 12)),
                      Text(PersianUtils.formatToman(balance),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_left, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.receipt_long_outlined,
            label: 'سفارش‌های من',
            color: AppColors.marketplacePurple,
            onTap: () => context.push(AppRoutes.orders),
          ),
          _MenuTile(
            icon: Icons.favorite_border,
            label: 'علاقه‌مندی‌ها',
            color: AppColors.accessoriesPink,
            onTap: () => context.push(AppRoutes.favorites),
          ),
          _MenuTile(
            icon: Icons.history,
            label: 'تاریخچه تراکنش‌ها',
            color: AppColors.cyan,
            onTap: () => context.push(AppRoutes.walletTransactions),
          ),
          if (ref.watch(isAdminProvider))
            _MenuTile(
              icon: Icons.admin_panel_settings_outlined,
              label: 'پنل مدیریت',
              color: AppColors.textPrimary,
              onTap: () => context.push(AppRoutes.admin),
            ),
          _MenuTile(
            icon: Icons.logout,
            label: 'خروج از حساب',
            color: AppColors.danger,
            onTap: () => ref.read(otpControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: Theme.of(context).textTheme.titleSmall),
        trailing: const Icon(Icons.chevron_left, color: AppColors.textMuted),
      ),
    );
  }
}
