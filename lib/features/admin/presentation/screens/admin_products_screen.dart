import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../marketplace/domain/entities/product.dart';
import '../providers/admin_providers.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت محصولات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('محصول جدید'),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = list[i];
            return ListTile(
              tileColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Text(p.title,
                  style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text(
                  '${p.category.label} • موجودی ${PersianUtils.toFa(p.stock.toString())}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(PersianUtils.formatToman(p.price),
                      style: Theme.of(context).textTheme.labelMedium),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _openForm(context, p),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.danger),
                    onPressed: () =>
                        ref.read(adminActionsProvider).deleteProduct(p.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openForm(BuildContext context, [Product? product]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductForm(product: product),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  const _ProductForm({this.product});
  final Product? product;

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  late final _title = TextEditingController(text: widget.product?.title);
  late final _price =
      TextEditingController(text: widget.product?.price.toString());
  late final _stock =
      TextEditingController(text: widget.product?.stock.toString());
  late final _subcategory =
      TextEditingController(text: widget.product?.subcategory);
  late final _image = TextEditingController(text: widget.product?.imageUrl);
  late final _desc = TextEditingController(text: widget.product?.description);
  late ProductCategory _category =
      widget.product?.category ?? ProductCategory.parts;
  bool _saving = false;

  int _toInt(TextEditingController c) =>
      int.tryParse(PersianUtils.toEn(c.text).replaceAll(RegExp(r'\D'), '')) ?? 0;

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{
      if (widget.product != null) 'id': widget.product!.id,
      'title': _title.text.trim(),
      'category': _category.name,
      'subcategory':
          _subcategory.text.trim().isEmpty ? null : _subcategory.text.trim(),
      'price': _toInt(_price),
      'stock': _toInt(_stock),
      'image_url': _image.text.trim().isEmpty ? null : _image.text.trim(),
      'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      'is_active': true,
    };
    final err = await ref.read(adminActionsProvider).saveProduct(data);
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
              Text(widget.product == null ? 'محصول جدید' : 'ویرایش محصول',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _field(_title, 'عنوان محصول'),
              SegmentedButton<ProductCategory>(
                segments: const [
                  ButtonSegment(
                      value: ProductCategory.parts, label: Text('قطعات')),
                  ButtonSegment(
                      value: ProductCategory.accessories,
                      label: Text('لوازم جانبی')),
                ],
                selected: {_category},
                onSelectionChanged: (s) => setState(() => _category = s.first),
              ),
              const SizedBox(height: 12),
              _field(_subcategory, 'زیردسته (کلید انگلیسی)'),
              Row(children: [
                Expanded(child: _field(_price, 'قیمت (تومان)')),
                const SizedBox(width: 12),
                Expanded(child: _field(_stock, 'موجودی')),
              ]),
              _field(_image, 'لینک تصویر (اختیاری)'),
              _field(_desc, 'توضیحات', maxLines: 2),
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

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in [_title, _price, _stock, _subcategory, _image, _desc]) {
      c.dispose();
    }
    super.dispose();
  }
}
