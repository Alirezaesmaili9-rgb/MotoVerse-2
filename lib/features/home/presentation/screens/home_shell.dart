import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../copilot/presentation/screens/copilot_screen.dart';
import '../../../garage/presentation/screens/garage_screen.dart';
import '../../../marketplace/presentation/screens/marketplace_screen.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../widgets/profile_tab.dart';
import 'home_screen.dart';

/// Bottom-nav shell. Layout matches the reference: five destinations with an
/// elevated center "گاراژ من" button. Tabs are kept alive via [IndexedStack].
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    CopilotScreen(),
    GarageScreen(),
    MarketplaceScreen(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: _MotoNav(
        index: _index,
        badge: unread,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _MotoNav extends StatelessWidget {
  const _MotoNav({
    required this.index,
    required this.onTap,
    required this.badge,
  });

  final int index;
  final ValueChanged<int> onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: 64 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bar
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: EdgeInsets.only(bottom: bottomInset, top: 6),
              child: Row(
                children: [
                  _NavItem(
                    selected: index == 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'خانه',
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    selected: index == 1,
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: 'پیام‌ها',
                    badge: badge,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(width: 64), // gap for the elevated button
                  _NavItem(
                    selected: index == 3,
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront,
                    label: 'فروشگاه',
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    selected: index == 4,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'پروفایل',
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
          // Elevated center "گاراژ من"
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.two_wheeler,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 2),
                    Text('گاراژ من',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: index == 2
                              ? AppColors.primary
                              : AppColors.primary,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? activeIcon : icon, color: color, size: 23),
                if (badge > 0)
                  Positioned(
                    top: -5,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                          color: AppColors.danger, shape: BoxShape.circle),
                      child: Text(
                        badge > 9 ? '+۹' : _fa(badge),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  static String _fa(int n) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return n.toString().split('').map((c) => fa[int.parse(c)]).join();
  }
}
