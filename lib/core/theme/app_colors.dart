import 'package:flutter/material.dart';

/// MotoVerse color tokens — the single source of truth for the palette.
/// Mirrors the brand design system (Revolut/Stripe/Linear-grade fintech feel).
class AppColors {
  const AppColors._();

  // Primary brand blue
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // Cyan
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFFCFFAFE);

  // Vertical accents
  static const Color marketplacePurple = Color(0xFF7C3AED);
  static const Color accessoriesPink = Color(0xFFEC4899);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Surfaces — light
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Text — light
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Surfaces — dark
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceSecondaryDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF1F2A3C);

  // Text — dark
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF64748B);

  // Gradients
  static const List<Color> brandGradient = [
    Color(0xFF2563EB),
    Color(0xFF3B82F6),
    Color(0xFF06B6D4),
  ];

  static const List<Color> motorHealthGradient = [
    Color(0xFF2563EB),
    Color(0xFF06B6D4),
    Color(0xFF22C55E),
  ];
}
