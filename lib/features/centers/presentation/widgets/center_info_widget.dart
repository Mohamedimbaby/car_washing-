import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/center_entity.dart';
import 'center_badge_row.dart';
import 'center_status_widgets.dart';

class CenterInfoWidget extends StatelessWidget {
  final CenterEntity center;

  const CenterInfoWidget({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            center.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          CenterRatingRow(center: center),
          const SizedBox(height: 5),
          CenterAddressRow(address: center.address),
          const SizedBox(height: 6),
          CenterBadgeRow(center: center),
        ],
      ),
    );
  }
}

class CenterRatingRow extends StatelessWidget {
  final CenterEntity center;

  const CenterRatingRow({super.key, required this.center});

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
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          ' (${center.reviewCount} reviews)',
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
        const Spacer(),
        const OpenStatusChip(),
      ],
    );
  }
}
