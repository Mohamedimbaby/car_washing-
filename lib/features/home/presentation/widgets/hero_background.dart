import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _HeroCirclePainter()),
    );
  }
}

class _HeroCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 1.1, size.height * 0.1),
      size.width * 0.55,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * -0.1, size.height * 0.9),
      size.width * 0.35,
      paint2,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
