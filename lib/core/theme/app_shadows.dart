import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Soft, fintech-grade shadow tokens.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0F172A), // rgba(15,23,42,0.06)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.25),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];
}
