import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../garage/domain/entities/motorcycle.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/entities/maintenance_status.dart';
import '../../domain/entities/maintenance_type.dart';
import '../providers/maintenance_providers.dart';
import '../widgets/add_maintenance_sheet.dart';

/// Per-motorcycle maintenance: actionable "service due in X km" status for each
/// item + the full service history. No health percentages (per product spec).
class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key, required this.motorcycle});

  final Motorcycle motorcycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(maintenanceRecordsProvider(motorcycle.id));

    return Scaffold(
      appBar: AppBar(title: Text('سرویس و نگهداری — ${motorcycle.displayName}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('ثبت سرویس'),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (records) {
          final statuses = _statuses(records);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MileageHeader(mileage: motorcycle.mileage),
              const SizedBox(height: 16),
              Text('وضعیت سرویس‌ها',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...statuses.map((s) => _StatusTile(status: s)),
              const SizedBox(height: 16),
              Text('تاریخچه سرویس', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (records.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('هنوز سرویسی ثبت نشده است')),
                )
              else
                ...records.map((r) => _RecordTile(
                      record: r,
                      onDelete: () => ref
                          .read(maintenanceActionsProvider)
                          .deleteRecord(r.id, motorcycle.id),
                    )),
            ],
          );
        },
      ),
    );
  }

  List<MaintenanceStatus> _statuses(List<MaintenanceRecord> records) {
    return MaintenanceType.values.map((type) {
      MaintenanceRecord? last;
      for (final r in records) {
        if (r.type == type) {
          last = r;
          break; // records are mileage-desc → first match is latest
        }
      }
      return MaintenanceStatus(
        type: type,
        currentMileage: motorcycle.mileage,
        lastRecord: last,
      );
    }).toList()
      ..sort((a, b) => a.remainingKm.compareTo(b.remainingKm));
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMaintenanceSheet(motorcycle: motorcycle),
    );
  }
}

class _MileageHeader extends StatelessWidget {
  const _MileageHeader({required this.mileage});
  final int mileage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.brandGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed, color: Colors.white),
          const SizedBox(width: 10),
          const Text('کیلومتر فعلی',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Text(PersianUtils.formatKm(mileage),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.status});
  final MaintenanceStatus status;

  Color get _color => switch (status.urgency) {
        MaintenanceUrgency.ok => AppColors.success,
        MaintenanceUrgency.soon => AppColors.warning,
        MaintenanceUrgency.due => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(status.type.label,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          Text(PersianUtils.toFa(status.message),
              style: TextStyle(
                  color: _color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.onDelete});
  final MaintenanceRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = PersianUtils.toFa(
        intl.DateFormat('yyyy/MM/dd').format(record.serviceDate));
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.type.label,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '$date • ${PersianUtils.formatKm(record.mileage)}'
                  '${record.serviceCenter != null ? ' • ${record.serviceCenter}' : ''}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (record.cost != null)
            Text(PersianUtils.formatToman(record.cost!),
                style: Theme.of(context).textTheme.labelMedium),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 20, color: AppColors.textMuted),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
