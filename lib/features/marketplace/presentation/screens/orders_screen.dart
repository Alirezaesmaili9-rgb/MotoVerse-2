import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/order.dart';
import '../providers/cart_providers.dart';

/// Orders list with an inline tracking timeline per order.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سفارش‌های من'),
        // Reachable both via push (from Profile) and via go() (after checkout).
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
      ),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('هنوز سفارشی ثبت نکرده‌ای'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderCard(order: list[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final MarketOrder order;

  @override
  Widget build(BuildContext context) {
    final date = PersianUtils.toFa(
        intl.DateFormat('yyyy/MM/dd').format(order.createdAt));

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
              Text('سفارش #${order.shortId}',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(date, style: Theme.of(context).textTheme.labelSmall),
          if (order.lines.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              order.lines
                  .map((l) =>
                      '${l.title} ×${PersianUtils.toFa(l.quantity.toString())}')
                  .join('، '),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          if (order.status != OrderStatus.cancelled)
            _Tracker(step: order.status.step),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مبلغ', style: Theme.of(context).textTheme.labelMedium),
              Text(PersianUtils.formatToman(order.total),
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final OrderStatus status;

  Color get _color => switch (status) {
        OrderStatus.delivered => AppColors.success,
        OrderStatus.cancelled => AppColors.danger,
        OrderStatus.shipped => AppColors.primary,
        _ => AppColors.warning,
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

/// Simple 4-step tracking timeline: paid → shipped → delivered.
class _Tracker extends StatelessWidget {
  const _Tracker({required this.step});
  final int step;

  static const _labels = ['ثبت', 'پرداخت', 'ارسال', 'تحویل'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  i <= step ? Icons.check : Icons.circle,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(_labels[i],
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          if (i < _labels.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: i < step ? AppColors.primary : AppColors.border,
              ),
            ),
        ],
      ],
    );
  }
}
