import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 4-column quick-action grid linking to the app's core modules.
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  static const _actions = <_Action>[
    _Action('موتوفیکس', Icons.health_and_safety_outlined, AppColors.primary),
    _Action('موتوسنج', Icons.price_change_outlined, AppColors.cyan),
    _Action('موتوتایپ', Icons.lightbulb_outline, AppColors.marketplacePurple),
    _Action('موتوبیمه', Icons.verified_user_outlined, AppColors.success),
    _Action('امداد', Icons.emergency_outlined, AppColors.danger),
    _Action('مارکت', Icons.storefront_outlined, AppColors.marketplacePurple),
    _Action('تعمیرگاه', Icons.location_on_outlined, AppColors.warning),
    _Action('راهنمای خرید', Icons.menu_book_outlined, Color(0xFF0284C7)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: _actions.map((a) => _ActionItem(action: a)).toList(),
    );
  }
}

class _Action {
  const _Action(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.action});
  final _Action action;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: action.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(action.icon, color: action.color, size: 26),
        ),
        const SizedBox(height: 7),
        Text(
          action.label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
