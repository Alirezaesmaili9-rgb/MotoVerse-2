import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/service_center.dart';
import '../providers/service_centers_providers.dart';
import '../widgets/booking_sheet.dart';

/// Locate nearby repair centers, read details, and book appointments.
class ServiceCentersScreen extends ConsumerWidget {
  const ServiceCentersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centers = ref.watch(serviceCentersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعمیرگاه‌ها'),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.bookings),
            child: const Text('رزروهای من'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (q) =>
                  ref.read(centersSearchProvider.notifier).state = q,
              decoration: const InputDecoration(
                hintText: 'جستجوی تعمیرگاه...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Map placeholder — google_maps_flutter is wired as a dependency;
          // rendering needs an API key + platform config.
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, color: AppColors.primary, size: 30),
                  SizedBox(height: 6),
                  Text('نمایش روی نقشه (نیازمند کلید Google Maps)',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.primaryHover)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: centers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطا: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('تعمیرگاهی یافت نشد'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _CenterCard(center: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterCard extends ConsumerWidget {
  const _CenterCard({required this.center});
  final ServiceCenter center;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.store_mall_directory_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.name,
                        style: Theme.of(context).textTheme.titleSmall),
                    if (center.address != null)
                      Text(center.address!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.warning),
                  Text(PersianUtils.toFa(center.rating.toStringAsFixed(1)),
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ],
          ),
          if (center.brands.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final b in center.brands)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(b,
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BookingSheet(center: center),
              ),
              child: const Text('رزرو وقت'),
            ),
          ),
        ],
      ),
    );
  }
}
