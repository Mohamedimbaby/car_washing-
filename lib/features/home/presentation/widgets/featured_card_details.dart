import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../centers/domain/entities/center_entity.dart';

class FeaturedCardRatingRow extends StatelessWidget {
  final CenterEntity center;

  const FeaturedCardRatingRow({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
        const SizedBox(width: 3),
        Text(
          center.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${center.reviewCount})',
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class FeaturedCardBadges extends StatelessWidget {
  final CenterEntity center;

  const FeaturedCardBadges({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (center.hasInCenterWash)
          const FeaturedBadgeChip('In-Center', AppColors.navyMedium),
        if (center.hasInCenterWash && center.hasOnLocationWash)
          const SizedBox(width: 4),
        if (center.hasOnLocationWash)
          const FeaturedBadgeChip('Mobile', AppColors.cyanDark),
      ],
    );
  }
}

class FeaturedBadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const FeaturedBadgeChip(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
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
