import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OpenStatusChip extends StatelessWidget {
  const OpenStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Open',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class CenterAddressRow extends StatelessWidget {
  final String address;

  const CenterAddressRow({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 12,
          color: AppColors.textHint,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
