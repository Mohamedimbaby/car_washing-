import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/service_package_entity.dart';
import '../../../slots/domain/entities/slot_entity.dart';
import '../cubit/booking_cubit.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import 'package:intl/intl.dart';

class TimeSlotSelectionPage extends StatefulWidget {
  final ServicePackageEntity package;
  final ServiceType serviceType;
  final String centerId;
  final String vehicleId;
  final List<String> addonIds;

  const TimeSlotSelectionPage({
    super.key,
    required this.package,
    required this.serviceType,
    required this.centerId,
    required this.vehicleId,
    required this.addonIds,
  });

  @override
  State<TimeSlotSelectionPage> createState() => _TimeSlotSelectionPageState();
}

class _TimeSlotSelectionPageState extends State<TimeSlotSelectionPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;
  List<TimeSlotItem> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate slot document ID
      final slotId =
          '${widget.centerId}_${selectedDate.year}${selectedDate.month.toString().padLeft(2, '0')}${selectedDate.day.toString().padLeft(2, '0')}';

      final slotDoc = await FirebaseFirestore.instance
          .collection(AppConfig.collectionPath('slots'))
          .doc(slotId)
          .get();

      if (slotDoc.exists && mounted) {
        final slotsData = slotDoc.data()?['slots'] as List<dynamic>? ?? [];
        final slots = slotsData.map((slot) {
          return TimeSlotItem(
            time: slot['time'] ?? '',
            capacity: slot['capacity'] ?? 0,
            booked: slot['booked'] ?? 0,
          );
        }).toList();

        // Filter slots that have enough consecutive availability
        final filteredSlots = _filterConsecutiveSlots(slots);

        setState(() {
          _availableSlots = filteredSlots;
          _isLoading = false;
        });
      } else {
        setState(() {
          _availableSlots = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableSlots = [];
          _isLoading = false;
        });
      }
    }
  }

  List<TimeSlotItem> _filterConsecutiveSlots(List<TimeSlotItem> allSlots) {
    final slotsNeeded = (widget.package.durationMinutes / 30).ceil();
    final List<TimeSlotItem> validSlots = [];

    for (int i = 0; i <= allSlots.length - slotsNeeded; i++) {
      bool allAvailable = true;

      // Check if all consecutive slots have availability
      for (int j = 0; j < slotsNeeded; j++) {
        final slot = allSlots[i + j];
        if (slot.booked >= slot.capacity) {
          allAvailable = false;
          break;
        }
      }

      if (allAvailable) {
        validSlots.add(allSlots[i]);
      }
    }

    return validSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date & Time'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _availableSlots.isEmpty
                    ? const Center(
                        child: Text('No time slots available for this date'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This ${widget.package.durationMinutes}-minute service will reserve your selected time slot',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Available Time Slots',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _availableSlots.map((slot) {
                              final isSelected = selectedTimeSlot == slot.time;
                              final availableSpots =
                                  slot.capacity - slot.booked;
                              return _buildTimeSlotCard(
                                slot,
                                isSelected,
                                availableSpots,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Date:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    selectedDate =
                        selectedDate.subtract(const Duration(days: 1));
                    selectedTimeSlot = null;
                  });
                  _loadTimeSlots();
                },
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      selectedTimeSlot = null;
                    });
                    _loadTimeSlots();
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 1));
                    selectedTimeSlot = null;
                  });
                  _loadTimeSlots();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(
    TimeSlotItem slot,
    bool isSelected,
    int availableSpots,
  ) {
    // Calculate end time based on package duration
    final timeParts = slot.time.split(':');
    final startHour = int.parse(timeParts[0]);
    final startMinute = int.parse(timeParts[1]);
    final endMinutes = startHour * 60 + startMinute + widget.package.durationMinutes;
    final endHour = endMinutes ~/ 60;
    final endMinute = endMinutes % 60;
    final endTime =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () {
        setState(() {
          selectedTimeSlot = isSelected ? null : slot.time;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: isSelected ? AppColors.white : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  slot.time,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Until $endTime',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.white.withOpacity(0.8)
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.white.withOpacity(0.2)
                    : _getCapacityColor(availableSpots, slot.capacity)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people,
                    size: 12,
                    color: isSelected
                        ? AppColors.white
                        : _getCapacityColor(availableSpots, slot.capacity),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getCapacityText(availableSpots, slot.capacity),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? AppColors.white
                          : _getCapacityColor(availableSpots, slot.capacity),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCapacityColor(int available, int total) {
    final ratio = available / total;
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.25) return Colors.orange;
    return Colors.red;
  }

  String _getCapacityText(int available, int total) {
    if (available == total) return '$available spots';
    if (available == 1) return 'Last spot!';
    return '$available spots left';
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child:             PrimaryButton(
          text: 'Confirm Booking',
          onPressed: selectedTimeSlot != null ? () => _confirmBooking() : () {},
        ),
      ),
    );
  }

  void _confirmBooking() {
    context.read<BookingCubit>().createBooking(
          vehicleId: widget.vehicleId,
          centerId: widget.centerId,
          serviceType: widget.serviceType,
          packageId: widget.package.id,
          addonIds: widget.addonIds,
          scheduledDate: selectedDate,
          timeSlot: selectedTimeSlot,
        );

    // Navigate to success page
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/booking-success',
      (route) => route.settings.name == '/home',
    );
  }
}
