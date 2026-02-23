import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HeroContentWidget extends StatelessWidget {
  const HeroContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional wash,\nat your convenience',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const _FindCenterButton(),
            ],
          ),
        ),
        const Icon(
          Icons.local_car_wash,
          size: 90,
          color: Colors.white12,
        ),
      ],
    );
  }
}

class _FindCenterButton extends StatelessWidget {
  const _FindCenterButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/search-centers'),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.cyan, AppColors.cyanDark],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Find a Center',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward, color: AppColors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
