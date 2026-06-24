import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/persian_utils.dart';
import '../../../insurance/domain/entities/insurance_policy.dart';
import '../providers/admin_providers.dart';

class AdminPoliciesScreen extends ConsumerWidget {
  const AdminPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policies = ref.watch(adminPoliciesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت بیمه‌ها')),
      body: policies.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = list[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(p.kind.label,
                          style: Theme.of(context).textTheme.titleSmall),
                      const Spacer(),
                      if (p.premium != null)
                        Text(PersianUtils.formatToman(p.premium!),
                            style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                  if (p.provider != null)
                    Text(p.provider!,
                        style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PolicyStatus>(
                    value: p.status,
                    decoration: const InputDecoration(
                        labelText: 'وضعیت', isDense: true),
                    items: [
                      for (final s in PolicyStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: (s) {
                      if (s != null) {
                        ref
                            .read(adminActionsProvider)
                            .setPolicyStatus(p.id, s.name);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
