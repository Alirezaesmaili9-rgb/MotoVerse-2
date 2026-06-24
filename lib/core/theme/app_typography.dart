import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale built on Vazirmatn (Persian-first, replaces Peyda/IRANSansX
/// for the open-source build). Weights: 400 / 500 / 600 / 700.
class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Vazirmatn';

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: _w(32, FontWeight.w700, primary, height: 1.2),
      displayMedium: _w(28, FontWeight.w700, primary, height: 1.2),
      headlineMedium: _w(22, FontWeight.w700, primary),
      titleLarge: _w(18, FontWeight.w700, primary),
      titleMedium: _w(16, FontWeight.w600, primary),
      titleSmall: _w(14, FontWeight.w600, primary),
      bodyLarge: _w(15, FontWeight.w400, primary, height: 1.6),
      bodyMedium: _w(14, FontWeight.w400, secondary, height: 1.6),
      bodySmall: _w(12, FontWeight.w400, secondary, height: 1.5),
      labelLarge: _w(14, FontWeight.w700, primary),
      labelMedium: _w(12, FontWeight.w600, secondary),
      labelSmall: _w(11, FontWeight.w500, secondary),
    );
  }

  static TextStyle _w(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
  }) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextTheme get light =>
      textTheme(AppColors.textPrimary, AppColors.textSecondary);

  static TextTheme get dark =>
      textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark);
}
