import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../garage/domain/entities/motorcycle.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/entities/maintenance_type.dart';
import '../providers/maintenance_providers.dart';

/// Logs a maintenance event. Defaults mileage to the bike's current reading and
/// the interval to the selected type's recommended value.
class AddMaintenanceSheet extends ConsumerStatefulWidget {
  const AddMaintenanceSheet({super.key, required this.motorcycle});

  final Motorcycle motorcycle;

  @override
  ConsumerState<AddMaintenanceSheet> createState() =>
      _AddMaintenanceSheetState();
}

class _AddMaintenanceSheetState extends ConsumerState<AddMaintenanceSheet> {
  MaintenanceType _type = MaintenanceType.engineOil;
  late final _mileage =
      TextEditingController(text: widget.motorcycle.mileage.toString());
  late final _interval =
      TextEditingController(text: _type.defaultIntervalKm.toString());
  final _cost = TextEditingController();
  final _center = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  int _toInt(TextEditingController c) =>
      int.tryParse(PersianUtils.toEn(c.text).replaceAll(RegExp(r'\D'), '')) ?? 0;

  void _onTypeChanged(MaintenanceType? t) {
    if (t == null) return;
    setState(() {
      _type = t;
      _interval.text = t.defaultIntervalKm.toString();
    });
  }

  Future<void> _save() async {
    final mileage = _toInt(_mileage);
    final interval = _toInt(_interval);
    if (interval <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بازه سرویس را وارد کنید')),
      );
      return;
    }
    setState(() => _saving = true);

    final record = MaintenanceRecord(
      id: '',
      motorcycleId: widget.motorcycle.id,
      type: _type,
      serviceDate: DateTime.now(),
      mileage: mileage,
      intervalKm: interval,
      cost: _cost.text.trim().isEmpty ? null : _toInt(_cost),
      serviceCenter: _center.text.trim().isEmpty ? null : _center.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );

    final err = await ref.read(maintenanceActionsProvider).addRecord(
          record,
          newMileage: mileage,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(err ??
              'سرویس ثبت شد — سرویس بعدی تا '
                  '${PersianUtils.formatKm(record.nextServiceMileage)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusSheet)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('ثبت سرویس جدید',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              DropdownButtonFormField<MaintenanceType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'نوع سرویس'),
                items: [
                  for (final t in MaintenanceType.values)
                    DropdownMenuItem(value: t, child: Text(t.label)),
                ],
                onChanged: _onTypeChanged,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_mileage, 'کیلومتر سرویس', number: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_interval, 'بازه بعدی (km)', number: true)),
              ]),
              _field(_cost, 'هزینه (تومان) — اختیاری', number: true),
              _field(_center, 'تعمیرگاه — اختیاری'),
              _field(_notes, 'یادداشت — اختیاری', maxLines: 2),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'ثبت سرویس',
                gradient: true,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in [_mileage, _interval, _cost, _center, _notes]) {
      c.dispose();
    }
    super.dispose();
  }
}
