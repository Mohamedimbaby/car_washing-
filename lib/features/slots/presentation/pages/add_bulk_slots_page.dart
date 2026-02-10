import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/slot_entity.dart';
import '../cubit/slot_cubit.dart';
import '../cubit/slot_state.dart';

class AddBulkSlotsPage extends StatefulWidget {
  const AddBulkSlotsPage({super.key});

  @override
  State<AddBulkSlotsPage> createState() => _AddBulkSlotsPageState();
}

class _AddBulkSlotsPageState extends State<AddBulkSlotsPage> {
  DateTimeRange? _dateRange;
  final List<TimeSlotItem> _slotTemplate = [];
  final Set<int> _selectedDaysOfWeek = {1, 2, 3, 4, 5, 6, 7}; // Default: all days
  
  final _timeController = TextEditingController();
  final _capacityController = TextEditingController();

  @override
  void dispose() {
    _timeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _timeController.text = formattedTime;
    }
  }

  void _addTimeSlot() {
    if (_timeController.text.isEmpty || _capacityController.text.isEmpty) {
      _showError('الرجاء إدخال الوقت والسعة / Please enter time and capacity');
      return;
    }

    final capacity = int.tryParse(_capacityController.text);
    if (capacity == null || capacity <= 0) {
      _showError('سعة غير صحيحة / Invalid capacity');
      return;
    }

    if (_slotTemplate.any((slot) => slot.time == _timeController.text)) {
      _showError('هذا الوقت موجود بالفعل / Time slot already exists');
      return;
    }

    setState(() {
      _slotTemplate.add(TimeSlotItem(
        time: _timeController.text,
        capacity: capacity,
      ));
      _timeController.clear();
      _capacityController.clear();
    });

    _slotTemplate.sort((a, b) => a.time.compareTo(b.time));
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _slotTemplate.removeAt(index);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _handleSubmit() {
    if (_dateRange == null) {
      _showError('الرجاء اختيار نطاق التواريخ / Please select date range');
      return;
    }

    if (_slotTemplate.isEmpty) {
      _showError('الرجاء إضافة موعد واحد على الأقل / Please add at least one time slot');
      return;
    }

    if (_selectedDaysOfWeek.isEmpty) {
      _showError('الرجاء اختيار يوم واحد على الأقل / Please select at least one day');
      return;
    }

    context.read<SlotCubit>().addBulkSlots(
      startDate: _dateRange!.start,
      endDate: _dateRange!.end,
      slotTemplate: _slotTemplate,
      daysOfWeek: _selectedDaysOfWeek.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مواعيد متعددة / Add Bulk Slots'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocListener<SlotCubit, SlotState>(
        listener: (context, state) {
          if (state is BulkSlotsAdded) {
            Navigator.pop(context);
          } else if (state is SlotError) {
            _showError(state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Range Selection
              _buildDateRangeSelector(dateFormat),
              const SizedBox(height: 24),

              // Days of Week Selection
              _buildDaysOfWeekSelector(),
              const SizedBox(height: 24),

              // Time Slot Template
              _buildTimeSlotEntry(),
              const SizedBox(height: 24),

              // Template List
              if (_slotTemplate.isNotEmpty) ...[
                const Text(
                  'نموذج المواعيد / Slot Template',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._slotTemplate.asMap().entries.map((entry) {
                  return _buildTimeSlotItem(entry.key, entry.value);
                }),
                const SizedBox(height: 24),
              ],

              // Summary
              if (_dateRange != null && _slotTemplate.isNotEmpty)
                _buildSummary(),
              const SizedBox(height: 24),

              // Submit Button
              BlocBuilder<SlotCubit, SlotState>(
                builder: (context, state) {
                  final isLoading = state is SlotLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'إضافة المواعيد / Add Slots',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(DateFormat dateFormat) {
    return Card(
      child: InkWell(
        onTap: _selectDateRange,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.date_range, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نطاق التواريخ / Date Range',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateRange != null
                          ? '${dateFormat.format(_dateRange!.start)} - ${dateFormat.format(_dateRange!.end)}'
                          : 'اختر التواريخ / Select dates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _dateRange != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekSelector() {
    final days = [
      {'value': 1, 'label': 'الإثنين\nMon'},
      {'value': 2, 'label': 'الثلاثاء\nTue'},
      {'value': 3, 'label': 'الأربعاء\nWed'},
      {'value': 4, 'label': 'الخميس\nThu'},
      {'value': 5, 'label': 'الجمعة\nFri'},
      {'value': 6, 'label': 'السبت\nSat'},
      {'value': 7, 'label': 'الأحد\nSun'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أيام الأسبوع / Days of Week',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: days.map((day) {
                final value = day['value'] as int;
                final isSelected = _selectedDaysOfWeek.contains(value);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDaysOfWeek.remove(value);
                      } else {
                        _selectedDaysOfWeek.add(value);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      day['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotEntry() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة موعد للنموذج / Add Time Slot to Template',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'الوقت / Time',
                      hintText: '09:00',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: _selectTime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'السعة / Capacity',
                      hintText: '3',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addTimeSlot,
                icon: const Icon(Icons.add),
                label: const Text('إضافة / Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotItem(int index, TimeSlotItem timeSlot) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.access_time,
            color: AppColors.success,
            size: 20,
          ),
        ),
        title: Text(
          timeSlot.time,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'السعة: ${timeSlot.capacity} / Capacity: ${timeSlot.capacity}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: () => _removeTimeSlot(index),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final days = _dateRange!.end.difference(_dateRange!.start).inDays + 1;
    final estimatedSlots = (days / 7 * _selectedDaysOfWeek.length).ceil();

    return Card(
      color: AppColors.info.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                SizedBox(width: 8),
                Text(
                  'ملخص / Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('• إجمالي الأيام / Total days: $days'),
            Text('• أيام محددة / Selected days: ${_selectedDaysOfWeek.length}'),
            Text('• مواعيد في اليوم / Slots per day: ${_slotTemplate.length}'),
            Text('• تقريبًا / Approximately: ~$estimatedSlots مواعيد / slots'),
          ],
        ),
      ),
    );
  }
}
