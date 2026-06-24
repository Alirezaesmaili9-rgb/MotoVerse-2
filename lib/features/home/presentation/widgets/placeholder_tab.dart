import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Lightweight scaffold for modules not yet implemented in this foundation
/// (Marketplace, Roadside, Profile, etc.). Keeps navigation coherent while the
/// remaining features are built out on top of the same architecture.
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('این بخش به‌زودی فعال می‌شود',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
