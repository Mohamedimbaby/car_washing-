import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashTaglineWidget extends StatelessWidget {
  const SplashTaglineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.cyan.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Powered by Washy™',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.white.withValues(alpha: 0.35),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
