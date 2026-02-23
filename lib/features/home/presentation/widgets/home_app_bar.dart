import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.navyDark,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/app_icon.png',
            width: 32,
            height: 32,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.local_car_wash,
              color: AppColors.cyan,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Washy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          _LocationChip(),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.15),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded,
              size: 14, color: AppColors.cyan),
          SizedBox(width: 4),
          Text(
            'Cairo, EG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 14, color: AppColors.white),
        ],
      ),
    );
  }
}
