import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/utils/persian_utils.dart';
import '../../../service_centers/domain/entities/service_booking.dart';
import '../providers/admin_providers.dart';

class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(adminBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت رزروها')),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final b = list[i];
            final date = b.scheduledAt == null
                ? 'بدون تاریخ'
                : PersianUtils.toFa(
                    intl.DateFormat('yyyy/MM/dd').format(b.scheduledAt!));
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.centerName ?? 'تعمیرگاه',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text('تاریخ: $date',
                      style: Theme.of(context).textTheme.labelSmall),
                  if (b.notes != null)
                    Text(b.notes!,
                        style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<BookingStatus>(
                    value: b.status,
                    decoration: const InputDecoration(
                        labelText: 'وضعیت', isDense: true),
                    items: [
                      for (final s in BookingStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: (s) {
                      if (s != null) {
                        ref
                            .read(adminActionsProvider)
                            .setBookingStatus(b.id, s.name);
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
