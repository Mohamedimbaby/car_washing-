import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/customer_entity.dart';
import '../cubit/provider_cubit.dart';
import '../cubit/provider_state.dart';
import '../widgets/provider_booking_card.dart';

class CustomerDetailsPage extends StatefulWidget {
  final CustomerEntity customer;

  const CustomerDetailsPage({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderCubit>().loadCustomerBookings(widget.customer.userId);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل العميل / Customer Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Customer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              border: const Border(
                bottom: BorderSide(color: AppColors.background, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: widget.customer.profilePhoto != null
                      ? NetworkImage(widget.customer.profilePhoto!)
                      : null,
                  child: widget.customer.profilePhoto == null
                      ? Text(
                          widget.customer.name.isNotEmpty
                              ? widget.customer.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  widget.customer.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  widget.customer.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'إجمالي الحجوزات\nTotal Bookings',
                      '${widget.customer.totalBookings}',
                      Icons.event,
                      AppColors.info,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.textSecondary.withOpacity(0.2),
                    ),
                    _buildStatItem(
                      'إجمالي الإيرادات\nTotal Revenue',
                      '${widget.customer.totalRevenue.toStringAsFixed(0)} EGP',
                      Icons.attach_money,
                      AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'آخر حجز: ${dateFormat.format(widget.customer.lastBookingDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Booking History
          Expanded(
            child: BlocBuilder<ProviderCubit, ProviderState>(
              builder: (context, state) {
                if (state is ProviderLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CustomerBookingsLoaded) {
                  if (state.bookings.isEmpty) {
                    return const Center(
                      child: Text('لا توجد حجوزات / No bookings'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.bookings.length,
                    itemBuilder: (context, index) {
                      final booking = state.bookings[index];
                      return ProviderBookingCard(
                        booking: booking,
                        onConfirm: () => context
                            .read<ProviderCubit>()
                            .confirmBooking(booking.id),
                        onComplete: () => context
                            .read<ProviderCubit>()
                            .completeBooking(booking.id),
                        onReport: () {}, // Disabled in history view
                      );
                    },
                  );
                }

                return const Center(
                  child: Text('لا توجد حجوزات / No bookings'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
