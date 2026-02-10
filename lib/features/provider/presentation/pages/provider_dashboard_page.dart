import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/provider_cubit.dart';
import '../cubit/provider_state.dart';
import '../widgets/stats_card.dart';
import '../widgets/provider_booking_card.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  late ProviderCubit _cubit ;
  @override
  void initState() {
    super.initState();
    _cubit = getIt<ProviderCubit>()..loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم / Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _cubit.loadDashboard(),
          ),
        ],
      ),
      body: BlocConsumer<ProviderCubit, ProviderState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is BookingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ProviderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProviderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProviderStatsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _cubit.loadDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    _buildStatsGrid(state),
                    const SizedBox(height: 24),

                    // Recent Bookings
                    _buildRecentBookingsSection(state),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.dashboard_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _cubit.loadDashboard(),
                  child: const Text('تحميل / Load Dashboard'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'slots',
            onPressed: () {
              Navigator.pushNamed(context, '/my-slots');
            },
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.event_available),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'packages',
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.myPackages);
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.inventory_2),
            label: const Text('باقاتي / Packages'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ProviderStatsLoaded state) {
    final stats = state.stats;
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الإحصائيات / Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            StatsCard(
              title: 'الحجوزات المعلقة',
              titleEn: 'Pending Bookings',
              value: stats.pendingBookings.toString(),
              icon: Icons.pending_actions,
              color: AppColors.warning,
            ),
            StatsCard(
              title: 'الحجوزات المكتملة',
              titleEn: 'Completed',
              value: stats.completedBookings.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
            StatsCard(
              title: 'إجمالي الدخل',
              titleEn: 'Total Income',
              value: '${formatter.format(stats.totalIncome)} EGP',
              icon: Icons.attach_money,
              color: AppColors.primary,
              isHighlighted: true,
            ),
            StatsCard(
              title: 'العملاء',
              titleEn: 'Customers',
              value: stats.totalCustomers.toString(),
              icon: Icons.people,
              color: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBookingsSection(ProviderStatsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الحجوزات الأخيرة / Recent Bookings',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/provider-bookings');
              },
              child: const Text('عرض الكل / View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.recentBookings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد حجوزات\nNo bookings yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.recentBookings.length,
            itemBuilder: (context, index) {
              final booking = state.recentBookings[index];
              return ProviderBookingCard(
                booking: booking,
                onConfirm: () {
                  _cubit.confirmBooking(booking.id);
                },
                onComplete: () {
                  _cubit.completeBooking(booking.id);
                },
                onReport: () {
                  _showReportDialog(context, booking.id);
                },
              );
            },
          ),
      ],
    );
  }

  Future<void> _showReportDialog(BuildContext context, String bookingId) async {
    final reasons = <String>[];
    final detailsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الإبلاغ عن الحجز / Report Booking'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: const Text('العميل لم يحضر / Customer no-show'),
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
                ),
                CheckboxListTile(
                  title: const Text('مركبة متسخة جداً / Extremely dirty'),
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
                ),
                CheckboxListTile(
                  title: const Text('مشكلة في الدفع / Payment issue'),
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
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل إضافية / Additional Details',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء / Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (reasons.isNotEmpty) {
                Navigator.pop(dialogContext);
                _cubit.reportBooking(
                      bookingId: bookingId,
                      reasons: reasons,
                      details: detailsController.text,
                    );
              }
            },
            child: const Text(
              'إبلاغ / Report',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    detailsController.dispose();
  }
}
