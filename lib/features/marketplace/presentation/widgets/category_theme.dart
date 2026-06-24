import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';

/// Per-vertical theming: parts → purple, accessories → pink.
class CategoryTheme {
  const CategoryTheme._();

  static Color color(ProductCategory category) =>
      category == ProductCategory.parts
          ? AppColors.marketplacePurple
          : AppColors.accessoriesPink;

  static List<Color> gradient(ProductCategory category) =>
      category == ProductCategory.parts
          ? const [AppColors.marketplacePurple, Color(0xFF6D28D9)]
          : const [AppColors.accessoriesPink, Color(0xFFBE185D)];

  static String emoji(ProductCategory category) =>
      category == ProductCategory.parts ? '🔧' : '🪖';
}
