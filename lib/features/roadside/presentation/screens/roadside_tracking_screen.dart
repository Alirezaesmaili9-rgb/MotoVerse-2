import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../domain/entities/roadside_request.dart';
import '../providers/roadside_providers.dart';

/// Live technician tracking — streams status/ETA updates from Supabase realtime.
class RoadsideTrackingScreen extends ConsumerWidget {
  const RoadsideTrackingScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(roadsideRequestStreamProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('پیگیری امداد')),
      body: stream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (req) => _Tracking(request: req, requestId: requestId),
      ),
    );
  }
}

class _Tracking extends ConsumerWidget {
  const _Tracking({required this.request, required this.requestId});
  final RoadsideRequest request;
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = request.status.isActive;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.brandGradient),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(request.kind.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(request.kind.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(request.status.label,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              if (request.etaMinutes != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'زمان تقریبی رسیدن: ${PersianUtils.toFa(request.etaMinutes.toString())} دقیقه',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        _StatusTimeline(status: request.status),
        const SizedBox(height: 24),
        if (active)
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(roadsideRepositoryProvider).cancel(requestId);
            },
            icon: const Icon(Icons.close, color: AppColors.danger),
            label: const Text('لغو درخواست',
                style: TextStyle(color: AppColors.danger)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: AppColors.danger),
            ),
          ),
        if (request.status == RoadsideStatus.done)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 10),
                Expanded(child: Text('خدمات امداد با موفقیت انجام شد.')),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});
  final RoadsideStatus status;

  static const _steps = [
    RoadsideStatus.requested,
    RoadsideStatus.assigned,
    RoadsideStatus.enroute,
    RoadsideStatus.done,
  ];

  @override
  Widget build(BuildContext context) {
    if (status == RoadsideStatus.cancelled) {
      return const Text('این درخواست لغو شده است.');
    }
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _Step(
            label: _steps[i].label,
            done: i <= status.step,
            isLast: i == _steps.length - 1,
            active: i == status.step,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.done,
    required this.isLast,
    required this.active,
  });

  final String label;
  final bool done;
  final bool isLast;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.primary : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(done ? Icons.check : Icons.circle,
                    size: 12, color: Colors.white),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: color)),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: done ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
