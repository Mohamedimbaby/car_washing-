import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/center_entity.dart';

class CenterBadgeRow extends StatelessWidget {
  final CenterEntity center;

  const CenterBadgeRow({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (center.hasInCenterWash)
          const CenterBadgeChip(label: 'In-Center', color: AppColors.navyMedium),
        if (center.hasInCenterWash && center.hasOnLocationWash)
          const SizedBox(width: 5),
        if (center.hasOnLocationWash)
          const CenterBadgeChip(label: 'Mobile', color: AppColors.cyanDark),
      ],
    );
  }
}

class CenterBadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const CenterBadgeChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
