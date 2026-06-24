import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/iranian_plate.dart';
import '../../../../core/widgets/mv_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../garage/presentation/providers/garage_providers.dart';
import '../../../maintenance/domain/entities/maintenance_status.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../widgets/quick_action_grid.dart';

/// The Home command center: welcome, primary motorcycle card with live plate,
/// the next actionable maintenance reminder, and quick actions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;
    final bike = ref.watch(primaryMotorcycleProvider);
    final nextMaintenance = ref.watch(nextMaintenanceProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(motorcyclesProvider);
            ref.invalidate(appUserProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            children: [
              _Welcome(name: user?.fullName),
              const SizedBox(height: 16),
              _BikeCard(
                title: bike?.displayName,
                subtitle: bike?.productionYear != null
                    ? 'مدل ${PersianUtils.toFa(bike!.productionYear.toString())}'
                    : 'موتورت را ثبت کن',
                plateTop: bike?.plateTop,
                plateBottom: bike?.plateBottom,
              ),
              const SizedBox(height: 12),
              if (nextMaintenance != null)
                _MaintenanceReminder(status: nextMaintenance),
              const SizedBox(height: 20),
              Text('دسترسی سریع',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              const QuickActionGrid(),
              const SizedBox(height: 20),
              _WalletStrip(balance: user?.walletBalance ?? 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({this.name});
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سلام${name != null ? '، $name' : ' رفیق'} 👋',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 2),
            Text('امروز موتورت چطوره؟',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.notifications_none, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _BikeCard extends StatelessWidget {
  const _BikeCard({
    this.title,
    this.subtitle,
    this.plateTop,
    this.plateBottom,
  });

  final String? title;
  final String? subtitle;
  final String? plateTop;
  final String? plateBottom;

  @override
  Widget build(BuildContext context) {
    return MvCard(
      gradient: const LinearGradient(
        colors: AppColors.brandGradient,
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('موتور من',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(title ?? 'موتورم را ثبت کن',
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
          const SizedBox(height: 16),
          IranianPlate(topNumber: plateTop, bottomNumber: plateBottom),
        ],
      ),
    );
  }
}

class _MaintenanceReminder extends StatelessWidget {
  const _MaintenanceReminder({required this.status});
  final MaintenanceStatus status;

  Color get _accent => switch (status.urgency) {
        MaintenanceUrgency.ok => AppColors.success,
        MaintenanceUrgency.soon => AppColors.warning,
        MaintenanceUrgency.due => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return MvCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.build_circle_outlined, color: _accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status.type.label,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                // Actionable message — no health percentages, per spec.
                Text(PersianUtils.toFa(status.message),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: _accent, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_left, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _WalletStrip extends StatelessWidget {
  const _WalletStrip({required this.balance});
  final int balance;

  @override
  Widget build(BuildContext context) {
    return MvCard(
      color: const Color(0xFF0F172A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('کیف پول MotoVerse',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 6),
              Text(PersianUtils.formatToman(balance),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          FilledButton.tonal(
            onPressed: () {},
            child: const Text('شارژ'),
          ),
        ],
      ),
    );
  }
}
