import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/persian_utils.dart';
import '../../../marketplace/domain/entities/order.dart';
import '../providers/admin_providers.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت سفارش‌ها')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final o = list[i];
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
                      Text('سفارش #${o.shortId}',
                          style: Theme.of(context).textTheme.titleSmall),
                      const Spacer(),
                      Text(PersianUtils.formatToman(o.total),
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                  if (o.lines.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      o.lines.map((l) => l.title).join('، '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  DropdownButtonFormField<OrderStatus>(
                    value: o.status,
                    decoration: const InputDecoration(
                        labelText: 'وضعیت', isDense: true),
                    items: [
                      for (final s in OrderStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: (s) {
                      if (s != null) {
                        ref
                            .read(adminActionsProvider)
                            .setOrderStatus(o.id, s.name);
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
