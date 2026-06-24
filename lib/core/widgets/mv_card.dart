import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_shadows.dart';

/// Standard white card with the brand's soft shadow and 20px radius.
class MvCard extends StatelessWidget {
  const MvCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.gradient,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? Theme.of(context).colorScheme.surface)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: gradient == null ? AppShadows.card : null,
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: card,
    );
  }
}
