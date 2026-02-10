import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OffDaysSelectorWidget extends StatelessWidget {
  final List<int> selectedOffDays;
  final ValueChanged<List<int>> onChanged;

  const OffDaysSelectorWidget({
    super.key,
    required this.selectedOffDays,
    required this.onChanged,
  });

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

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
                Icon(Icons.event_busy, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Off Days',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select days you want to exclude from slot generation',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final dayNumber = index + 1; // 1=Monday, 7=Sunday
                final isSelected = selectedOffDays.contains(dayNumber);
                
                return FilterChip(
                  label: Text(_dayNames[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newOffDays = List<int>.from(selectedOffDays);
                    if (selected) {
                      newOffDays.add(dayNumber);
                    } else {
                      newOffDays.remove(dayNumber);
                    }
                    newOffDays.sort();
                    onChanged(newOffDays);
                  },
                  selectedColor: Colors.red.shade100,
                  checkmarkColor: Colors.red.shade700,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.red.shade700 : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }),
            ),
            if (selectedOffDays.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Off days: ${selectedOffDays.map((d) => _dayNames[d - 1]).join(', ')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
