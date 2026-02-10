import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/domain/entities/booking_entity.dart';

class ProviderBookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onReport;

  const ProviderBookingCard({
    super.key,
    required this.booking,
    this.onConfirm,
    this.onComplete,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(),
                Text(
                  '\$${booking.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Booking Details
            _buildInfoRow(
              Icons.calendar_today,
              DateFormat('MMM dd, yyyy').format(booking.scheduledDate),
              booking.timeSlot ?? '',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.person,
              'عميل / Customer',
              booking.userId,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.directions_car,
              'مركبة / Vehicle',
              booking.vehicleId,
            ),
            
            if (booking.specialInstructions != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.specialInstructions!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String textAr;
    String textEn;

    switch (booking.status) {
      case BookingStatus.pending:
        bgColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        textAr = 'معلق';
        textEn = 'Pending';
        break;
      case BookingStatus.confirmed:
        bgColor = AppColors.info.withOpacity(0.2);
        textColor = AppColors.info;
        textAr = 'مؤكد';
        textEn = 'Confirmed';
        break;
      case BookingStatus.inProgress:
        bgColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        textAr = 'جاري التنفيذ';
        textEn = 'In Progress';
        break;
      case BookingStatus.completed:
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        textAr = 'مكتمل';
        textEn = 'Completed';
        break;
      case BookingStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        textAr = 'ملغى';
        textEn = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$textAr / $textEn',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final List<Widget> buttons = [];

    if (booking.status == BookingStatus.pending && onConfirm != null) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('تأكيد / Confirm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
          ),
        ),
      );
    }

    if (booking.status == BookingStatus.confirmed && onComplete != null) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('إنهاء / Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ),
      );
    }

    if ((booking.status == BookingStatus.pending ||
            booking.status == BookingStatus.confirmed) &&
        onReport != null) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 8));
      }
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReport,
            icon: const Icon(Icons.report, size: 18),
            label: const Text('إبلاغ / Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: buttons);
  }
}
