import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/admin_user.dart';
import '../providers/admin_providers.dart';

/// User management: view all users, toggle admin role, send a notification.
class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت کاربران')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _UserTile(user: list[i]),
        ),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});
  final AdminUser user;

  Future<void> _notify(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ارسال اعلان'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: title,
                decoration: const InputDecoration(hintText: 'عنوان')),
            const SizedBox(height: 8),
            TextField(
                controller: body,
                decoration: const InputDecoration(hintText: 'متن')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('انصراف')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ارسال')),
        ],
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      final err = await ref.read(adminActionsProvider).sendNotification(
            userId: user.id,
            title: title.text.trim(),
            body: body.text.trim().isEmpty ? null : body.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err ?? 'اعلان ارسال شد ✓')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(user.isAdmin ? '👑' : '🏍'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName ?? 'کاربر',
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(user.phone ?? user.id.substring(0, 8),
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              Text(PersianUtils.formatToman(user.walletBalance),
                  style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: Text(user.isAdmin ? 'ادمین' : 'کاربر عادی'),
                selected: user.isAdmin,
                onSelected: (sel) async {
                  final err = await ref
                      .read(adminActionsProvider)
                      .setUserRole(user.id, sel ? 'admin' : 'rider');
                  if (context.mounted && err != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(err)));
                  }
                },
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _notify(context, ref),
                icon: const Icon(Icons.notifications_outlined, size: 18),
                label: const Text('اعلان'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
