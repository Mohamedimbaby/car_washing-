import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/slot_entity.dart';

class SlotCardWidget extends StatelessWidget {
  final SlotEntity slot;
  final VoidCallback onDelete;

  const SlotCardWidget({
    super.key,
    required this.slot,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final totalCapacity = slot.slots.fold<int>(0, (sum, s) => sum + s.capacity);
    final totalBooked = slot.slots.fold<int>(0, (sum, s) => sum + s.booked);
    final totalAvailable = totalCapacity - totalBooked;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(slot.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${slot.slots.length} مواعيد / time slots',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  'السعة / Capacity',
                  '$totalCapacity',
                  Icons.event_seat,
                  AppColors.primary,
                ),
                _buildStat(
                  'محجوز / Booked',
                  '$totalBooked',
                  Icons.check_circle,
                  AppColors.success,
                ),
                _buildStat(
                  'متاح / Available',
                  '$totalAvailable',
                  Icons.event_available,
                  totalAvailable > 0 ? AppColors.info : AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time Slots
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slot.slots.map((timeSlot) {
                return _buildTimeSlotChip(timeSlot);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotChip(TimeSlotItem timeSlot) {
    final available = timeSlot.available;
    final isFull = timeSlot.isFull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isFull
            ? AppColors.error.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFull ? AppColors.error : AppColors.success,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFull ? Icons.block : Icons.check_circle_outline,
            size: 14,
            color: isFull ? AppColors.error : AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            timeSlot.time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFull ? AppColors.error : AppColors.success,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($available/${timeSlot.capacity})',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
