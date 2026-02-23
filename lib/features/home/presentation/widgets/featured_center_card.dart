import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../centers/domain/entities/center_entity.dart';
import 'center_card_image.dart';
import 'featured_card_details.dart';

class FeaturedCenterCard extends StatelessWidget {
  final CenterEntity center;
  final VoidCallback? onTap;

  const FeaturedCenterCard({super.key, required this.center, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CenterCardImage(center: center),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    center.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FeaturedCardRatingRow(center: center),
                  const SizedBox(height: 6),
                  FeaturedCardBadges(center: center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
