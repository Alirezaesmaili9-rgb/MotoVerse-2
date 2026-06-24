import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/roadside_request.dart';
import '../providers/roadside_providers.dart';

/// Roadside assistance hub: pick a service type to dispatch a request.
class RoadsideScreen extends ConsumerWidget {
  const RoadsideScreen({super.key});

  Future<void> _request(
      BuildContext context, WidgetRef ref, RoadsideKind kind) async {
    final (id, error) = await ref.read(createRoadsideProvider)(kind);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.push(AppRoutes.roadsideTracking, extra: id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('امداد جاده‌ای'),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.roadsideHistory),
            child: const Text('تاریخچه'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.danger, Color(0xFFDC2626)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(Icons.sos_outlined, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('به کمک نیاز داری؟',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                  'نوع خدمت را انتخاب کن تا نزدیک‌ترین امدادگر برایت ارسال شود',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('نوع خدمات امداد',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              for (final kind in RoadsideKind.values)
                _ServiceTile(
                  kind: kind,
                  onTap: () => _request(context, ref, kind),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _EmergencyNumbers(),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.kind, required this.onTap});
  final RoadsideKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0F0F172A), blurRadius: 16)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(kind.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(kind.label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _EmergencyNumbers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تماس اضطراری', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          _row(context, '🚨', 'اورژانس', '۱۱۵'),
          const Divider(),
          _row(context, '🛣️', 'امداد جاده‌ای پلیس', '۱۹۷'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String emoji, String title, String number) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(number,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.danger)),
      ],
    );
  }
}
