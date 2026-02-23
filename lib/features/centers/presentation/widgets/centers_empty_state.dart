import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CentersEmptyState extends StatelessWidget {
  const CentersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 72,
          color: AppColors.textHint,
        ),
        SizedBox(height: 16),
        Text(
          'No centers found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Try searching by a different name or location',
          style: TextStyle(fontSize: 13, color: AppColors.textHint),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
