import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/insurance_policy.dart';
import '../providers/insurance_providers.dart';

/// "My insurance" — active policies with renewal reminders.
class PoliciesScreen extends ConsumerWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policies = ref.watch(policiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('بیمه‌های من')),
      body: policies.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 64, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('هنوز بیمه‌ای ثبت نکرده‌ای'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _PolicyCard(policy: list[i]),
          );
        },
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.policy});
  final InsurancePolicy policy;

  @override
  Widget build(BuildContext context) {
    final end = policy.endDate == null
        ? '—'
        : PersianUtils.toFa(intl.DateFormat('yyyy/MM/dd').format(policy.endDate!));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(policy.kind.label,
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              _StatusChip(status: policy.status),
            ],
          ),
          const SizedBox(height: 8),
          if (policy.provider != null)
            Text(policy.provider!,
                style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('تاریخ انقضا: $end',
                  style: Theme.of(context).textTheme.bodySmall),
              if (policy.premium != null)
                Text(PersianUtils.formatToman(policy.premium!),
                    style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          if (policy.isExpiringSoon) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'یادآور تمدید: تنها ${PersianUtils.toFa(policy.daysToExpiry.toString())} روز تا پایان بیمه',
                      style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final PolicyStatus status;

  Color get _color => switch (status) {
        PolicyStatus.active => AppColors.success,
        PolicyStatus.expired => AppColors.danger,
        PolicyStatus.pending => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.label,
          style: TextStyle(
              color: _color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
