import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tools/domain/entities/embedded_tool.dart';

/// 4-column quick-action grid linking to the app's core modules.
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <_Action>[
      _Action('موتوفیکس', Icons.health_and_safety_outlined, AppColors.primary,
          () => context.push(AppRoutes.toolView, extra: EmbeddedTool.motofix)),
      _Action('موتوسنج', Icons.price_change_outlined, AppColors.cyan,
          () => context.push(AppRoutes.toolView, extra: EmbeddedTool.motosanj)),
      _Action('موتوتایپ', Icons.lightbulb_outline, AppColors.marketplacePurple,
          () => context.push(AppRoutes.toolView, extra: EmbeddedTool.mototype)),
      _Action('موتوبیمه', Icons.verified_user_outlined, AppColors.success, null),
      _Action('امداد', Icons.emergency_outlined, AppColors.danger, null),
      _Action('مارکت', Icons.storefront_outlined, AppColors.marketplacePurple,
          () => context.push(AppRoutes.marketplace)),
      _Action('تعمیرگاه', Icons.location_on_outlined, AppColors.warning, null),
      _Action('ابزارها', Icons.auto_awesome_outlined, const Color(0xFF0284C7),
          () => context.push(AppRoutes.tools)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: actions.map((a) => _ActionItem(action: a)).toList(),
    );
  }
}

class _Action {
  const _Action(this.label, this.icon, this.color, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.action});
  final _Action action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
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
      ),
    );
  }
}
