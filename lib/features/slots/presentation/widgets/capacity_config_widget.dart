import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CapacityConfigWidget extends StatelessWidget {
  final int capacity;
  final ValueChanged<int> onChanged;

  const CapacityConfigWidget({
    super.key,
    required this.capacity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Washing Capacity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'How many cars can you wash at the same time?',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: capacity > 1
                      ? () => onChanged(capacity - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    capacity.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: capacity < 10
                      ? () => onChanged(capacity + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '$capacity car${capacity > 1 ? 's' : ''} per time slot',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
