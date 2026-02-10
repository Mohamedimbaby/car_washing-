import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/slot_entity.dart';
import '../cubit/slot_cubit.dart';
import '../cubit/slot_state.dart';

class MySlotsPage extends StatefulWidget {
  const MySlotsPage({super.key});

  @override
  State<MySlotsPage> createState() => _MySlotsPageState();
}

class _MySlotsPageState extends State<MySlotsPage> {
  String? _providerId;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _providerId = user.uid;
    });

    context.read<SlotCubit>().loadSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Slots / مواعيدي'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSlots,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<SlotCubit, SlotState>(
        builder: (context, state) {
          if (state is SlotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SlotError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadSlots,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SlotsLoaded) {
            if (state.slots.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No slots created yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لم يتم إنشاء مواعيد بعد',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add-slot');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Slots / إنشاء مواعيد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Group slots by date
            final slotsByDate = <DateTime, SlotEntity>{};
            for (var slot in state.slots) {
              final dateKey = DateTime(slot.date.year, slot.date.month, slot.date.day);
              slotsByDate[dateKey] = slot;
            }

            // Sort dates
            final sortedDates = slotsByDate.keys.toList()..sort();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final slotEntity = slotsByDate[date]!;
                
                return _SlotDayCard(
                  date: date,
                  slotEntity: slotEntity,
                );
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-slot');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Slots'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _SlotDayCard extends StatefulWidget {
  final DateTime date;
  final SlotEntity slotEntity;

  const _SlotDayCard({
    required this.date,
    required this.slotEntity,
  });

  @override
  State<_SlotDayCard> createState() => _SlotDayCardState();
}

class _SlotDayCardState extends State<_SlotDayCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalSlots = widget.slotEntity.slots.length;
    final bookedSlots = widget.slotEntity.slots.where((s) => s.booked > 0).length;
    final fullyBookedSlots = widget.slotEntity.slots
        .where((s) => s.booked >= s.capacity)
        .length;
    final availableSlots = totalSlots - fullyBookedSlots;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd').format(widget.date),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(widget.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(widget.date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _StatusBadge(
                              label: '$availableSlots available',
                              color: Colors.green,
                              icon: Icons.check_circle_outline,
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(
                              label: '$bookedSlots booked',
                              color: Colors.orange,
                              icon: Icons.event_available,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time Slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.slotEntity.slots.map((timeSlot) {
                      return _TimeSlotChip(
                        timeSlot: timeSlot,
                        onTap: () {
                          if (timeSlot.booked > 0) {
                            _showBookingDetails(context, timeSlot);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showBookingDetails(BuildContext context, TimeSlotItem timeSlot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  timeSlot.time,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM dd, yyyy').format(widget.date),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const Divider(height: 32),
            _DetailRow(
              icon: Icons.people,
              label: 'Capacity',
              value: '${timeSlot.capacity} cars',
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.event_available,
              label: 'Booked',
              value: '${timeSlot.booked} cars',
              valueColor: Colors.orange,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.event_seat,
              label: 'Available',
              value: '${timeSlot.capacity - timeSlot.booked} spots',
              valueColor: Colors.green,
            ),
            const SizedBox(height: 24),
            if (timeSlot.booked > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'To view booking details, check the "My Bookings" page',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final TimeSlotItem timeSlot;
  final VoidCallback onTap;

  const _TimeSlotChip({
    required this.timeSlot,
    required this.onTap,
  });

  Color get _statusColor {
    if (timeSlot.booked >= timeSlot.capacity) return Colors.red;
    if (timeSlot.booked > 0) return Colors.orange;
    return Colors.green;
  }

  String get _statusText {
    if (timeSlot.booked >= timeSlot.capacity) return 'Full';
    if (timeSlot.booked > 0) return '${timeSlot.capacity - timeSlot.booked} left';
    return 'Available';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _statusColor.withOpacity(0.1),
          border: Border.all(color: _statusColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 14, color: _statusColor),
                const SizedBox(width: 4),
                Text(
                  timeSlot.time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 10,
                color: _statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
