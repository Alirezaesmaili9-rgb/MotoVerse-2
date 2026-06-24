import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/persian_utils.dart';

/// Faithful recreation of the Iranian motorcycle license plate.
///
/// Renders the user's actual plate dynamically — pass [topNumber] (3 digits)
/// and [bottomNumber] (5 digits). When values are empty, neutral placeholders
/// are shown instead of dummy numbers (per spec: "remove placeholder numbers").
class IranianPlate extends StatelessWidget {
  const IranianPlate({
    super.key,
    this.topNumber,
    this.bottomNumber,
    this.scale = 1.0,
  });

  final String? topNumber;
  final String? bottomNumber;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final hasTop = (topNumber ?? '').trim().isNotEmpty;
    final hasBottom = (bottomNumber ?? '').trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 7 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // Plate reads RTL in Iran but the flag block sits on the left edge.
        textDirection: TextDirection.ltr,
        children: [
          _FlagBlock(scale: scale),
          SizedBox(width: 8 * scale),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasTop ? PersianUtils.toFa(topNumber!) : '— — —',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: hasTop ? const Color(0xFF1A1A1A) : AppColors.textMuted,
                  height: 1,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                hasBottom ? PersianUtils.toFa(bottomNumber!) : '— — — — —',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color:
                      hasBottom ? const Color(0xFF1A1A1A) : AppColors.textMuted,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlagBlock extends StatelessWidget {
  const _FlagBlock({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2 * scale),
          child: SizedBox(
            width: 28 * scale,
            height: 18 * scale,
            child: Column(
              children: const [
                Expanded(child: ColoredBox(color: Color(0xFF239F40))),
                Expanded(child: ColoredBox(color: Colors.white)),
                Expanded(child: ColoredBox(color: Color(0xFFDA0000))),
              ],
            ),
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          'I.R.\nIRAN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 8 * scale,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: const Color(0xFF003580),
          ),
        ),
      ],
    );
  }
}
