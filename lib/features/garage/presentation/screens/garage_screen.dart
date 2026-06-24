import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/iranian_plate.dart';
import '../../../../core/widgets/mv_card.dart';
import '../../domain/entities/motorcycle.dart';
import '../providers/garage_providers.dart';
import '../widgets/motorcycle_form_sheet.dart';

/// My Garage — list of registered motorcycles with quick add.
class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikesAsync = ref.watch(motorcyclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('گاراژ من')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('افزودن موتور'),
      ),
      body: bikesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (bikes) {
          if (bikes.isEmpty) return const _EmptyGarage();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bikes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _MotorcycleTile(
              bike: bikes[i],
              onEdit: () => _openForm(context, bikes[i]),
            ),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, [Motorcycle? existing]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MotorcycleFormSheet(existing: existing),
    );
  }
}

class _MotorcycleTile extends StatelessWidget {
  const _MotorcycleTile({required this.bike, required this.onEdit});
  final Motorcycle bike;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return MvCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.two_wheeler, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(bike.displayName,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (bike.isPrimary)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('اصلی',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IranianPlate(
                topNumber: bike.plateTop,
                bottomNumber: bike.plateBottom,
                scale: 0.85,
              ),
              const Spacer(),
              Text(PersianUtils.formatKm(bike.mileage),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyGarage extends StatelessWidget {
  const _EmptyGarage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.two_wheeler, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('هنوز موتوری ثبت نکرده‌ای',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('برای شخصی‌سازی اپ، موتورت را اضافه کن',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
