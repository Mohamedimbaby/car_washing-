import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../cubit/provider_cubit.dart';
import '../cubit/provider_state.dart';
import '../widgets/provider_booking_card.dart';

enum BookingFilter { all, pending, confirmed, completed, reported, cancelled }

class ProviderBookingsPage extends StatefulWidget {
  const ProviderBookingsPage({super.key});

  @override
  State<ProviderBookingsPage> createState() => _ProviderBookingsPageState();
}

class _ProviderBookingsPageState extends State<ProviderBookingsPage> {
  BookingFilter _selectedFilter = BookingFilter.all;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    context.read<ProviderCubit>().loadProviderBookings();
  }

  List<BookingEntity> _filterBookings(List<BookingEntity> bookings) {
    switch (_selectedFilter) {
      case BookingFilter.all:
        return bookings;
      case BookingFilter.pending:
        return bookings.where((b) => b.status == 'pending').toList();
      case BookingFilter.confirmed:
        return bookings.where((b) => b.status == 'confirmed').toList();
      case BookingFilter.completed:
        return bookings.where((b) => b.status == 'completed').toList();
      case BookingFilter.reported:
        return bookings.where((b) => b.status == 'reported').toList();
      case BookingFilter.cancelled:
        return bookings.where((b) => b.status == 'cancelled').toList();
    }
  }

  String _getFilterLabel(BookingFilter filter) {
    switch (filter) {
      case BookingFilter.all:
        return 'الكل / All';
      case BookingFilter.pending:
        return 'معلق / Pending';
      case BookingFilter.confirmed:
        return 'مؤكد / Confirmed';
      case BookingFilter.completed:
        return 'مكتمل / Completed';
      case BookingFilter.reported:
        return 'مُبلغ / Reported';
      case BookingFilter.cancelled:
        return 'ملغي / Cancelled';
    }
  }

  Color _getFilterColor(BookingFilter filter) {
    switch (filter) {
      case BookingFilter.all:
        return AppColors.textPrimary;
      case BookingFilter.pending:
        return AppColors.warning;
      case BookingFilter.confirmed:
        return AppColors.info;
      case BookingFilter.completed:
        return AppColors.success;
      case BookingFilter.reported:
        return AppColors.error;
      case BookingFilter.cancelled:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي / My Bookings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),

          // Bookings List
          Expanded(
            child: BlocBuilder<ProviderCubit, ProviderState>(
              builder: (context, state) {
                if (state is ProviderLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProviderBookingsLoaded) {
                  final filteredBookings = _filterBookings(state.bookings);

                  if (filteredBookings.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadBookings(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return ProviderBookingCard(
                          booking: booking,
                          onConfirm: () => context
                              .read<ProviderCubit>()
                              .confirmBooking(booking.id),
                          onComplete: () => context
                              .read<ProviderCubit>()
                              .completeBooking(booking.id),
                          onReport: () => _showReportDialog(booking.id),
                        );
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: BookingFilter.values.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_getFilterLabel(filter)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  }
                },
                selectedColor: _getFilterColor(filter).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected
                      ? _getFilterColor(filter)
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? _getFilterColor(filter)
                      : AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد حجوزات ${_getFilterLabel(_selectedFilter)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No ${_selectedFilter.name} bookings',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReportDialog(String bookingId) async {
    final reasons = <String>[];
    String? additionalDetails;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('الإبلاغ عن الحجز / Report Booking'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر السبب / Select reason:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text(
                      'العميل لم يحضر\nCustomer no-show',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: reasons.contains('customer_no_show'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          reasons.add('customer_no_show');
                        } else {
                          reasons.remove('customer_no_show');
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'السيارة غير نظيفة بشكل غير عادي\nExtremely dirty vehicle',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: reasons.contains('extremely_dirty'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          reasons.add('extremely_dirty');
                        } else {
                          reasons.remove('extremely_dirty');
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'مشكلة في الدفع\nPayment issue',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: reasons.contains('payment_issue'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          reasons.add('payment_issue');
                        } else {
                          reasons.remove('payment_issue');
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'سلوك غير لائق\nInappropriate behavior',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: reasons.contains('inappropriate_behavior'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          reasons.add('inappropriate_behavior');
                        } else {
                          reasons.remove('inappropriate_behavior');
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'تفاصيل إضافية / Additional Details',
                      border: OutlineInputBorder(),
                      hintText: 'اكتب هنا...',
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      additionalDetails = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء / Cancel'),
              ),
              TextButton(
                onPressed: reasons.isEmpty
                    ? null
                    : () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('إبلاغ / Report'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ProviderCubit>().reportBooking(
            bookingId: bookingId,
            reasons: reasons,
            details: additionalDetails ?? '',
          );
    }
  }
}
