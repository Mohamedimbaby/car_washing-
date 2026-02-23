import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashBackgroundWidget extends StatelessWidget {
  const SplashBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _SplashOrbPainter()),
    );
  }
}

class _SplashOrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final p2 = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.45,
      p1,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.85),
      size.width * 0.35,
      p2,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
