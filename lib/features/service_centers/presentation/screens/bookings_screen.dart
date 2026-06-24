import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/service_booking.dart';
import '../providers/service_centers_providers.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('رزروهای من')),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy_outlined,
                      size: 64, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('رزروی ثبت نشده است'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _BookingCard(booking: list[i]),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final ServiceBooking booking;

  Color get _color => switch (booking.status) {
        BookingStatus.confirmed => AppColors.success,
        BookingStatus.done => AppColors.primary,
        BookingStatus.cancelled => AppColors.danger,
        BookingStatus.requested => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    final date = booking.scheduledAt == null
        ? 'بدون تاریخ'
        : PersianUtils.toFa(
            intl.DateFormat('yyyy/MM/dd').format(booking.scheduledAt!));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.centerName ?? 'تعمیرگاه',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text('تاریخ: $date',
                    style: Theme.of(context).textTheme.bodySmall),
                if (booking.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(booking.notes!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(booking.status.label,
                style: TextStyle(
                    color: _color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
