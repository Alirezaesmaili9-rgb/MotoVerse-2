import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/admin_stats.dart';
import '../providers/admin_providers.dart';

/// Admin dashboard: analytics overview + entry points to each management area.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('پنل مدیریت')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminStatsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('آمار کلی', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            stats.when(
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator())),
              error: (e, _) => Text('خطا: $e'),
              data: (s) => _StatsGrid(stats: s),
            ),
            const SizedBox(height: 24),
            Text('مدیریت', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _NavTile(
              icon: Icons.people_outline,
              label: 'کاربران',
              color: AppColors.primary,
              onTap: () => context.push(AppRoutes.adminUsers),
            ),
            _NavTile(
              icon: Icons.inventory_2_outlined,
              label: 'محصولات مارکت‌پلیس',
              color: AppColors.marketplacePurple,
              onTap: () => context.push(AppRoutes.adminProducts),
            ),
            _NavTile(
              icon: Icons.receipt_long_outlined,
              label: 'سفارش‌ها',
              color: AppColors.cyan,
              onTap: () => context.push(AppRoutes.adminOrders),
            ),
            _NavTile(
              icon: Icons.newspaper_outlined,
              label: 'اخبار (دنیای موتور)',
              color: AppColors.warning,
              onTap: () => context.push(AppRoutes.adminNews),
            ),
            _NavTile(
              icon: Icons.emergency_outlined,
              label: 'درخواست‌های امداد',
              color: AppColors.danger,
              onTap: () => context.push(AppRoutes.adminRoadside),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, String value, IconData icon, Color color})>[
      (
        label: 'کاربران',
        value: PersianUtils.formatNumber(stats.users),
        icon: Icons.people_outline,
        color: AppColors.primary
      ),
      (
        label: 'سفارش‌ها',
        value: PersianUtils.formatNumber(stats.orders),
        icon: Icons.shopping_bag_outlined,
        color: AppColors.marketplacePurple
      ),
      (
        label: 'درآمد (تومان)',
        value: PersianUtils.formatNumber(stats.revenue),
        icon: Icons.payments_outlined,
        color: AppColors.success
      ),
      (
        label: 'محصولات',
        value: PersianUtils.formatNumber(stats.products),
        icon: Icons.inventory_2_outlined,
        color: AppColors.cyan
      ),
      (
        label: 'امداد فعال',
        value: PersianUtils.formatNumber(stats.activeRoadside),
        icon: Icons.emergency_outlined,
        color: AppColors.danger
      ),
      (
        label: 'رزرو در انتظار',
        value: PersianUtils.formatNumber(stats.pendingBookings),
        icon: Icons.event_outlined,
        color: AppColors.warning
      ),
      (
        label: 'بیمه‌ها',
        value: PersianUtils.formatNumber(stats.policies),
        icon: Icons.verified_user_outlined,
        color: AppColors.success
      ),
      (
        label: 'اخبار',
        value: PersianUtils.formatNumber(stats.news),
        icon: Icons.newspaper_outlined,
        color: AppColors.primary
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        for (final it in items)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x0F0F172A), blurRadius: 16)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(it.icon, color: it.color, size: 22),
                Text(it.value,
                    style: Theme.of(context).textTheme.titleLarge),
                Text(it.label,
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
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
