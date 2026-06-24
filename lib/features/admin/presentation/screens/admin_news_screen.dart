import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../motor_world/domain/entities/news_article.dart';
import '../providers/admin_providers.dart';

class AdminNewsScreen extends ConsumerWidget {
  const AdminNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(adminNewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت اخبار')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('خبر جدید'),
      ),
      body: news.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final a = list[i];
            return ListTile(
              tileColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Text(a.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text(a.tag ?? a.source ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _openForm(context, a),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.danger),
                    onPressed: () =>
                        ref.read(adminActionsProvider).deleteNews(a.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openForm(BuildContext context, [NewsArticle? article]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewsForm(article: article),
    );
  }
}

class _NewsForm extends ConsumerStatefulWidget {
  const _NewsForm({this.article});
  final NewsArticle? article;

  @override
  ConsumerState<_NewsForm> createState() => _NewsFormState();
}

class _NewsFormState extends ConsumerState<_NewsForm> {
  late final _title = TextEditingController(text: widget.article?.title);
  late final _summary = TextEditingController(text: widget.article?.summary);
  late final _body = TextEditingController(text: widget.article?.body);
  late final _tag = TextEditingController(text: widget.article?.tag);
  late final _source = TextEditingController(text: widget.article?.source);
  bool _published = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{
      if (widget.article != null) 'id': widget.article!.id,
      'title': _title.text.trim(),
      'summary': _summary.text.trim().isEmpty ? null : _summary.text.trim(),
      'body': _body.text.trim().isEmpty ? null : _body.text.trim(),
      'tag': _tag.text.trim().isEmpty ? null : _tag.text.trim(),
      'source': _source.text.trim().isEmpty ? null : _source.text.trim(),
      'is_published': _published,
    };
    final err = await ref.read(adminActionsProvider).saveNews(data);
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
              Text(widget.article == null ? 'خبر جدید' : 'ویرایش خبر',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _field(_title, 'عنوان'),
              _field(_summary, 'خلاصه'),
              _field(_body, 'متن کامل', maxLines: 4),
              Row(children: [
                Expanded(child: _field(_tag, 'تگ')),
                const SizedBox(width: 12),
                Expanded(child: _field(_source, 'منبع')),
              ]),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('منتشر شود'),
                value: _published,
                onChanged: (v) => setState(() => _published = v),
              ),
              const SizedBox(height: 8),
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
    for (final c in [_title, _summary, _body, _tag, _source]) {
      c.dispose();
    }
    super.dispose();
  }
}
