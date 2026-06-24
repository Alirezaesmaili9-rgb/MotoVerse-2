import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../service_centers/domain/entities/service_center.dart';
import '../providers/admin_providers.dart';

class AdminCentersScreen extends ConsumerWidget {
  const AdminCentersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centers = ref.watch(adminCentersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت تعمیرگاه‌ها')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('تعمیرگاه جدید'),
      ),
      body: centers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final c = list[i];
            return ListTile(
              tileColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Text(c.name,
                  style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text(c.address ?? c.brands.join('، ')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _openForm(context, c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.danger),
                    onPressed: () => ref
                        .read(adminActionsProvider)
                        .deleteServiceCenter(c.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openForm(BuildContext context, [ServiceCenter? center]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CenterForm(center: center),
    );
  }
}

class _CenterForm extends ConsumerStatefulWidget {
  const _CenterForm({this.center});
  final ServiceCenter? center;

  @override
  ConsumerState<_CenterForm> createState() => _CenterFormState();
}

class _CenterFormState extends ConsumerState<_CenterForm> {
  late final _name = TextEditingController(text: widget.center?.name);
  late final _address = TextEditingController(text: widget.center?.address);
  late final _brands =
      TextEditingController(text: widget.center?.brands.join('، '));
  late final _phone = TextEditingController(text: widget.center?.phone);
  bool _saving = false;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final brands = _brands.text
        .split(RegExp('[,،]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final data = <String, dynamic>{
      if (widget.center != null) 'id': widget.center!.id,
      'name': _name.text.trim(),
      'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
      'brands': brands,
      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    };
    final err = await ref.read(adminActionsProvider).saveServiceCenter(data);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
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
              Text(widget.center == null ? 'تعمیرگاه جدید' : 'ویرایش تعمیرگاه',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _field(_name, 'نام تعمیرگاه'),
              _field(_address, 'آدرس'),
              _field(_brands, 'برندها (با ویرگول جدا کنید)'),
              _field(_phone, 'تلفن'),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'ذخیره',
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

  Widget _field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
            controller: c, decoration: InputDecoration(labelText: label)),
      );

  @override
  void dispose() {
    for (final c in [_name, _address, _brands, _phone]) {
      c.dispose();
    }
    super.dispose();
  }
}
