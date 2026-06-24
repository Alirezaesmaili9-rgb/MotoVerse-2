import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../garage/presentation/providers/garage_providers.dart';
import '../../domain/entities/insurance_offer.dart';
import '../../domain/entities/insurance_policy.dart';
import '../providers/insurance_providers.dart';

/// MotoBimeh: pick an insurance kind, compare provider offers, buy online.
class InsuranceScreen extends ConsumerWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = ref.watch(selectedInsuranceKindProvider);
    final offers = ref.watch(insuranceOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('موتوبیمه'),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.policies),
            child: const Text('بیمه‌های من'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                for (final k in InsuranceKind.values)
                  ChoiceChip(
                    label: Text(k.label),
                    selected: kind == k,
                    onSelected: (_) => ref
                        .read(selectedInsuranceKindProvider.notifier)
                        .state = k,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(kind.description,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
          Expanded(
            child: offers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطا: $e')),
              data: (list) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) =>
                    _OfferCard(offer: list[i], isBest: i == 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends ConsumerWidget {
  const _OfferCard({required this.offer, required this.isBest});

  final InsuranceOffer offer;
  final bool isBest;

  Future<void> _buy(BuildContext context, WidgetRef ref) async {
    final bike = ref.read(primaryMotorcycleProvider);
    if (bike == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا موتورت را در گاراژ ثبت کن')),
      );
      return;
    }
    final error = await ref.read(buyInsuranceProvider)(
      motorcycleId: bike.id,
      offer: offer,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(error ??
              'درخواست صدور بیمه ${offer.provider} ثبت شد. کارشناس با شما '
                  'تماس می‌گیرد ✓')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isBest
            ? Border.all(color: AppColors.success, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(offer.provider,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              if (isBest)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('بهترین قیمت',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              const Spacer(),
              const Icon(Icons.star, size: 14, color: AppColors.warning),
              Text(PersianUtils.toFa(offer.rating.toStringAsFixed(1)),
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final h in offer.highlights)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(h,
                      style: Theme.of(context).textTheme.labelSmall),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('حق بیمه سالانه',
                      style: Theme.of(context).textTheme.labelSmall),
                  Text(PersianUtils.formatToman(offer.premium),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.primary)),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _buy(context, ref),
                child: const Text('خرید آنلاین'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
