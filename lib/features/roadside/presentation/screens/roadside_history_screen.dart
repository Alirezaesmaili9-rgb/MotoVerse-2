import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/roadside_request.dart';
import '../providers/roadside_providers.dart';

class RoadsideHistoryScreen extends ConsumerWidget {
  const RoadsideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(roadsideHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تاریخچه امداد')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('درخواستی ثبت نشده است'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _HistoryTile(request: list[i]),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.request});
  final RoadsideRequest request;

  @override
  Widget build(BuildContext context) {
    final date = PersianUtils.toFa(
        intl.DateFormat('yyyy/MM/dd  HH:mm').format(request.createdAt));
    final color = request.status.isActive
        ? AppColors.warning
        : (request.status == RoadsideStatus.done
            ? AppColors.success
            : AppColors.textMuted);

    return ListTile(
      tileColor: Theme.of(context).colorScheme.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Text(request.kind.emoji, style: const TextStyle(fontSize: 24)),
      title: Text(request.kind.label,
          style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(date, style: Theme.of(context).textTheme.labelSmall),
      trailing: Text(request.status.label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      onTap: request.status.isActive
          ? () => context.push(AppRoutes.roadsideTracking, extra: request.id)
          : null,
    );
  }
}
