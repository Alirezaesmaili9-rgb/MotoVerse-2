import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../roadside/domain/entities/roadside_request.dart';
import '../providers/admin_providers.dart';

class AdminRoadsideScreen extends ConsumerWidget {
  const AdminRoadsideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(adminRoadsideProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت امداد')),
      body: requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _RoadsideTile(request: list[i]),
        ),
      ),
    );
  }
}

class _RoadsideTile extends ConsumerWidget {
  const _RoadsideTile({required this.request});
  final RoadsideRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = PersianUtils.toFa(
        intl.DateFormat('yyyy/MM/dd  HH:mm').format(request.createdAt));

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
              Text(request.kind.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(request.kind.label,
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Text(date, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<RoadsideStatus>(
                  value: request.status,
                  decoration: const InputDecoration(
                      labelText: 'وضعیت', isDense: true),
                  items: [
                    for (final s in RoadsideStatus.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (s) {
                    if (s != null) {
                      ref
                          .read(adminActionsProvider)
                          .updateRoadside(request.id, status: s.name);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EtaField(
                  initial: request.etaMinutes,
                  onSubmit: (eta) => ref
                      .read(adminActionsProvider)
                      .updateRoadside(request.id, etaMinutes: eta),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EtaField extends StatelessWidget {
  const _EtaField({required this.initial, required this.onSubmit});
  final int? initial;
  final ValueChanged<int> onSubmit;

  @override
  Widget build(BuildContext context) {
    final controller =
        TextEditingController(text: initial?.toString() ?? '');
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'ETA (دقیقه)',
        isDense: true,
        suffixIcon: Icon(Icons.check, size: 18, color: AppColors.success),
      ),
      onSubmitted: (v) {
        final eta = int.tryParse(PersianUtils.toEn(v));
        if (eta != null) onSubmit(eta);
      },
    );
  }
}
