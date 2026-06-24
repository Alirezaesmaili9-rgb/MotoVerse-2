import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../garage/presentation/providers/garage_providers.dart';
import '../../domain/entities/service_center.dart';
import '../providers/service_centers_providers.dart';

/// Bottom sheet to request an appointment at a service center.
class BookingSheet extends ConsumerStatefulWidget {
  const BookingSheet({super.key, required this.center});

  final ServiceCenter center;

  @override
  ConsumerState<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends ConsumerState<BookingSheet> {
  DateTime? _date;
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final bike = ref.read(primaryMotorcycleProvider);
    final error = await ref.read(bookServiceProvider)(
      serviceCenterId: widget.center.id,
      motorcycleId: bike?.id,
      scheduledAt: _date,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'درخواست رزرو ثبت شد ✓')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _date == null
        ? 'انتخاب تاریخ'
        : PersianUtils.toFa(intl.DateFormat('yyyy/MM/dd').format(_date!));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusSheet)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رزرو وقت — ${widget.center.name}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(dateLabel),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                  hintText: 'توضیحات (نوع سرویس، مشکل موتور...)'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'ثبت درخواست رزرو',
              gradient: true,
              isLoading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
