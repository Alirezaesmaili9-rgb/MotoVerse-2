import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../garage/presentation/screens/garage_screen.dart';
import '../../../marketplace/presentation/screens/marketplace_screen.dart';
import '../widgets/placeholder_tab.dart';
import '../widgets/profile_tab.dart';
import 'home_screen.dart';

/// Bottom-nav shell hosting the five primary destinations. Tabs are kept alive
/// via [IndexedStack] so scroll position and state persist across switches.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    GarageScreen(),
    MarketplaceScreen(),
    PlaceholderTab(title: 'امداد جاده‌ای', icon: Icons.emergency_outlined),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'خانه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.garage_outlined),
            activeIcon: Icon(Icons.garage),
            label: 'گاراژ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'مارکت',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency_outlined),
            activeIcon: Icon(Icons.emergency),
            label: 'امداد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'من',
          ),
        ],
      ),
    );
  }
}
