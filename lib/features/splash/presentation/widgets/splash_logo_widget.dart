import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'splash_icon_widget.dart';

class SplashLogoWidget extends StatelessWidget {
  final Animation<double> fade;
  final Animation<double> scale;

  const SplashLogoWidget({
    super.key,
    required this.fade,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SplashIconWidget(),
            SizedBox(height: 24),
            _AppNameText(),
            SizedBox(height: 8),
            _TaglineText(),
          ],
        ),
      ),
    );
  }
}

class _AppNameText extends StatelessWidget {
  const _AppNameText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Washy',
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        letterSpacing: 1,
      ),
    );
  }
}

class _TaglineText extends StatelessWidget {
  const _TaglineText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Premium Car Wash on Demand',
      style: TextStyle(
        fontSize: 15,
        color: AppColors.white.withValues(alpha: 0.6),
        letterSpacing: 0.5,
      ),
    );
  }
}
