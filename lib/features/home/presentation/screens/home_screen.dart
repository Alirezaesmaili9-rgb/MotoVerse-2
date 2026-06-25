import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/persian_utils.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../garage/presentation/providers/garage_providers.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../tools/domain/entities/embedded_tool.dart';

/// Home command center — laid out to match the approved reference design:
/// centered logo top bar, hero card, service-reminder card, 4×2 quick-action
/// cards, and an insurance banner. (No health-score gauge, per product rule.)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;
    final bike = ref.watch(primaryMotorcycleProvider);
    final next = ref.watch(nextMaintenanceProvider);
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(motorcyclesProvider);
            ref.invalidate(appUserProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _TopBar(
                unread: unread,
                onBell: () => context.push(AppRoutes.notifications),
              ),
              const SizedBox(height: 12),
              _HeroCard(
                bikeName: bike?.displayName,
                mileage: bike?.mileage,
                serviceLine: next == null
                    ? 'موتورت را در گاراژ ثبت کن'
                    : '${next.type.label} — ${PersianUtils.toFa(next.message)}',
                onTapService: bike == null
                    ? () => context.push(AppRoutes.garage)
                    : () => context.push(AppRoutes.maintenance, extra: bike),
              ),
              const SizedBox(height: 14),
              _ServiceReminderCard(
                onReserve: () => context.push(AppRoutes.serviceCenters),
              ),
              const SizedBox(height: 14),
              _QuickGrid(),
              const SizedBox(height: 16),
              _InsuranceBanner(
                onTap: () => context.push(AppRoutes.insurance),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.unread, required this.onBell});
  final int unread;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _IconBtn(
          icon: Icons.notifications_none,
          showDot: unread > 0,
          onTap: onBell,
        ),
        Row(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(text: 'Moto', style: TextStyle(color: AppColors.textPrimary)),
                  TextSpan(text: 'Verse', style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
          ],
        ),
        _IconBtn(icon: Icons.menu, onTap: () {}),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, this.showDot = false, this.onTap});
  final IconData icon;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            if (showDot)
              Positioned(
                top: 11,
                right: 12,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    this.bikeName,
    this.mileage,
    required this.serviceLine,
    required this.onTapService,
  });

  final String? bikeName;
  final int? mileage;
  final String serviceLine;
  final VoidCallback onTapService;

  @override
  Widget build(BuildContext context) {
    final subtitle = bikeName == null
        ? 'به MotoVerse خوش آمدی'
        : '$bikeName · ${PersianUtils.formatKm(mileage ?? 0)}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Hero top with skyline-ish gradient + motorcycle art
          Container(
            height: 168,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFEAF3FF), Color(0xFFF4F9FF), Colors.white],
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: -10,
                  bottom: -8,
                  child: Icon(Icons.two_wheeler,
                      size: 150, color: Color(0xFF1E293B)),
                ),
                Positioned(
                  right: 18,
                  top: 18,
                  left: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('سلام، رایدر! 👋',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text('آماده‌ی یک سفر امن هستی',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              height: 1.4)),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer: actionable service reminder
          InkWell(
            onTap: onTapService,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.build_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('یادآور سرویس',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13.5)),
                        const SizedBox(height: 2),
                        Text(serviceLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceReminderCard extends StatelessWidget {
  const _ServiceReminderCard({required this.onReserve});
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('۱۵',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900, height: 1)),
                SizedBox(height: 3),
                Text('روز دیگر',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سرویس دوره‌ای بعدی',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                SizedBox(height: 4),
                Text('۱۵ اردیبهشت ۱۴۰۳ / با ۱۴,۴۰۰ کیلومتر',
                    style: TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          FilledButton(
            onPressed: onReserve,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('رزرو سرویس',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.74,
      children: [
        _QuickCard(
          icon: Icons.verified_user_outlined,
          color: AppColors.primary,
          title: 'بیمه',
          subtitle: 'خدمات بیمه‌ای متنوع',
          onTap: () => context.push(AppRoutes.insurance),
        ),
        _QuickCard(
          icon: Icons.support_agent_outlined,
          color: AppColors.success,
          title: 'امداد جاده‌ای',
          subtitle: '۲۴ ساعته در کنار شما',
          onTap: () => context.push(AppRoutes.roadside),
        ),
        _QuickCard(
          icon: Icons.health_and_safety_outlined,
          color: AppColors.marketplacePurple,
          title: 'عیب‌یاب هوشمند',
          subtitle: 'تشخیص سریع مشکلات موتور',
          onTap: () =>
              context.push(AppRoutes.toolView, extra: EmbeddedTool.motofix),
        ),
        _QuickCard(
          icon: Icons.trending_up,
          color: AppColors.warning,
          title: 'قیمت‌گذاری موتور',
          subtitle: 'ارزش روز موتورها',
          onTap: () =>
              context.push(AppRoutes.toolView, extra: EmbeddedTool.motosanj),
        ),
        _QuickCard(
          icon: Icons.shopping_cart_outlined,
          color: AppColors.accessoriesPink,
          title: 'فروشگاه',
          subtitle: 'لوازم جانبی و قطعات یدکی',
          onTap: () => context.push(AppRoutes.marketplace),
        ),
        _QuickCard(
          icon: Icons.event_available_outlined,
          color: AppColors.cyan,
          title: 'یادآوری سرویس‌ها',
          subtitle: 'هیچ سرویسی را از دست ندهید',
          onTap: () => context.push(AppRoutes.garage),
        ),
        _QuickCard(
          icon: Icons.menu_book_outlined,
          color: AppColors.primary,
          title: 'راهنمای موتورسیکلت',
          subtitle: 'مقالات و نکات آموزشی',
          onTap: () => context.push(AppRoutes.motorWorld),
        ),
        _QuickCard(
          icon: Icons.handyman_outlined,
          color: AppColors.marketplacePurple,
          title: 'خدمات و تعمیرگاه',
          subtitle: 'بهترین تعمیرگاه‌ها',
          onTap: () => context.push(AppRoutes.serviceCenters),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 7),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 11.5)),
            const SizedBox(height: 3),
            Text(subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 9.5, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _InsuranceBanner extends StatelessWidget {
  const _InsuranceBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFEAF3FF)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.two_wheeler, size: 54, color: Color(0xFF1E293B)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('آرامش در هر سفر',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text(
                    'با بیمه‌های متنوع موتورس، سفرهای خود را ایمن کنید.',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.7),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('مشاهده بیمه‌ها',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),
            Icon(Icons.verified_user_outlined,
                size: 50, color: AppColors.primary.withOpacity(0.45)),
          ],
        ),
      ),
    );
  }
}
