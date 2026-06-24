import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The three self-contained HTML tools embedded (unmodified) via WebView.
enum EmbeddedTool {
  motofix(
    id: 'motofix',
    title: 'موتوفیکس',
    subtitle: 'عیب‌یاب هوشمند موتورسیکلت',
    assetPath: 'assets/tools/motofix.html',
    accent: AppColors.primary,
  ),
  motosanj(
    id: 'motosanj',
    title: 'موتوسنج',
    subtitle: 'ارزیاب قیمت موتور کارکرده',
    assetPath: 'assets/tools/motosanj.html',
    accent: AppColors.cyan,
  ),
  mototype(
    id: 'mototype',
    title: 'موتوتایپ',
    subtitle: 'راهنمای انتخاب موتور مناسب',
    assetPath: 'assets/tools/mototype.html',
    accent: AppColors.marketplacePurple,
  );

  const EmbeddedTool({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.accent,
  });

  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final Color accent;

  IconData get icon => switch (this) {
        EmbeddedTool.motofix => Icons.health_and_safety_outlined,
        EmbeddedTool.motosanj => Icons.price_change_outlined,
        EmbeddedTool.mototype => Icons.lightbulb_outline,
      };

  static EmbeddedTool fromId(String id) =>
      values.firstWhere((t) => t.id == id, orElse: () => EmbeddedTool.motofix);
}
