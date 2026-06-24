import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/motorcycle.dart';
import '../providers/garage_providers.dart';

/// Bottom sheet to register or edit a motorcycle. Uses the Iranian plate
/// split (3-digit top + 5-digit bottom) per the design.
class MotorcycleFormSheet extends ConsumerStatefulWidget {
  const MotorcycleFormSheet({super.key, this.existing});

  final Motorcycle? existing;

  @override
  ConsumerState<MotorcycleFormSheet> createState() =>
      _MotorcycleFormSheetState();
}

class _MotorcycleFormSheetState extends ConsumerState<MotorcycleFormSheet> {
  late final _brand = TextEditingController(text: widget.existing?.brand);
  late final _model = TextEditingController(text: widget.existing?.model);
  late final _year =
      TextEditingController(text: widget.existing?.productionYear?.toString());
  late final _engineCc =
      TextEditingController(text: widget.existing?.engineCc?.toString());
  late final _mileage =
      TextEditingController(text: widget.existing?.mileage.toString());
  late final _plateTop = TextEditingController(text: widget.existing?.plateTop);
  late final _plateBottom =
      TextEditingController(text: widget.existing?.plateBottom);

  bool _saving = false;

  int? _parseInt(TextEditingController c) {
    final t = PersianUtils.toEn(c.text).replaceAll(RegExp(r'\D'), '');
    return t.isEmpty ? null : int.tryParse(t);
  }

  Future<void> _save() async {
    if (_brand.text.trim().isEmpty || _model.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برند و مدل موتور را وارد کنید')),
      );
      return;
    }
    setState(() => _saving = true);

    final base = widget.existing;
    final bike = Motorcycle(
      id: base?.id ?? '',
      ownerId: base?.ownerId ?? '',
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      productionYear: _parseInt(_year),
      engineCc: _parseInt(_engineCc),
      mileage: _parseInt(_mileage) ?? 0,
      plateTop: _plateTop.text.trim().isEmpty ? null : _plateTop.text.trim(),
      plateBottom:
          _plateBottom.text.trim().isEmpty ? null : _plateBottom.text.trim(),
      isPrimary: base?.isPrimary ?? true,
    );

    final notifier = ref.read(motorcyclesProvider.notifier);
    if (base == null) {
      await notifier.add(bike);
    } else {
      await notifier.update(bike);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusSheet),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.existing == null
                    ? 'افزودن موتور جدید'
                    : 'ویرایش اطلاعات موتور',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              _field(_brand, 'برند موتور', hint: 'مثلاً هوندا'),
              _field(_model, 'مدل موتور', hint: 'مثلاً PCX 160'),
              Row(children: [
                Expanded(child: _field(_year, 'سال تولید', hint: '۱۴۰۲')),
                const SizedBox(width: 12),
                Expanded(child: _field(_engineCc, 'حجم موتور (cc)', hint: '۱۶۰')),
              ]),
              _field(_mileage, 'کیلومتر فعلی', hint: '۱۲۵۰۰'),
              Row(children: [
                Expanded(
                    child: _field(_plateTop, 'پلاک — سه رقم بالا', hint: '۱۲۳')),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_plateBottom, 'پلاک — پنج رقم پایین',
                        hint: '۵۶۷۸۹')),
              ]),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'ذخیره اطلاعات',
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

  Widget _field(TextEditingController c, String label, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _brand,
      _model,
      _year,
      _engineCc,
      _mileage,
      _plateTop,
      _plateBottom,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
