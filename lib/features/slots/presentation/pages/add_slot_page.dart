import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../domain/entities/schedule_config_entity.dart';
import '../cubit/schedule_cubit.dart';
import '../cubit/schedule_state.dart';
import '../widgets/capacity_config_widget.dart';
import '../widgets/date_range_picker_widget.dart';
import '../widgets/working_hours_widget.dart';
import '../widgets/off_days_selector_widget.dart';

class AddSlotPage extends StatefulWidget {
  const AddSlotPage({super.key});

  @override
  State<AddSlotPage> createState() => _AddSlotPageState();
}

class _AddSlotPageState extends State<AddSlotPage> {
  int _capacity = 3;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  List<int> _offDays = []; // Empty = all days working
  DateTime _dateRangeStart = DateTime.now();
  DateTime _dateRangeEnd = DateTime.now().add(const Duration(days: 30));
  int _slotDuration = 30;
  
  String? _providerId;
  String? _configId;
  DateTime? _lastGenerated;

  @override
  void initState() {
    super.initState();
    _loadScheduleConfig();
  }

  Future<void> _loadScheduleConfig() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _providerId = user.uid;
    });

    context.read<ScheduleCubit>().loadScheduleConfig(user.uid);
  }

  void _saveConfiguration() {
    if (_providerId == null) return;

    final config = ScheduleConfigEntity(
      id: _configId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      providerId: _providerId!,
      appId: AppConfig.appId,
      washingCapacity: _capacity,
      workingStartTime: _startTime,
      workingEndTime: _endTime,
      offDays: _offDays,
      dateRangeStart: _dateRangeStart,
      dateRangeEnd: _dateRangeEnd,
      slotDurationMinutes: _slotDuration,
      createdAt: DateTime.now(),
      lastGenerated: _lastGenerated,
    );

    context.read<ScheduleCubit>().saveConfig(config);
  }

  void _generateSlots() {
    if (_providerId == null) return;

    // Use current date as placeholder since repository uses config dates
    context.read<ScheduleCubit>().generateSlots(
          providerId: _providerId!,
          month: DateTime.now(),
        );
  }

  int _calculateWorkingDays() {
    int count = 0;
    for (var date = _dateRangeStart;
        date.isBefore(_dateRangeEnd.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      if (!_offDays.contains(date.weekday)) {
        count++;
      }
    }
    return count;
  }

  int _calculateSlotsPerDay() {
    final totalMinutes = (_endTime.hour * 60 + _endTime.minute) -
        (_startTime.hour * 60 + _startTime.minute);
    return (totalMinutes / _slotDuration).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة موعد / Add Slot'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleConfigLoaded && state.config != null) {
            setState(() {
              _configId = state.config!.id;
              _capacity = state.config!.washingCapacity;
              _startTime = state.config!.workingStartTime;
              _endTime = state.config!.workingEndTime;
              _offDays = state.config!.offDays;
              _dateRangeStart = state.config!.dateRangeStart;
              _dateRangeEnd = state.config!.dateRangeEnd;
              _slotDuration = state.config!.slotDurationMinutes;
              _lastGenerated = state.config!.lastGenerated;
            });
          } else if (state is ScheduleSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SlotsGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back after successful generation
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          } else if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScheduleGenerating) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Generating slots... ${(state.progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'جاري إنشاء المواعيد...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Capacity Configuration
                CapacityConfigWidget(
                  capacity: _capacity,
                  onChanged: (value) {
                    setState(() {
                      _capacity = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 2. Date Range
                DateRangePickerWidget(
                  startDate: _dateRangeStart,
                  endDate: _dateRangeEnd,
                  onStartChanged: (date) {
                    setState(() {
                      _dateRangeStart = date;
                      if (_dateRangeEnd.isBefore(_dateRangeStart)) {
                        _dateRangeEnd = _dateRangeStart.add(const Duration(days: 30));
                      }
                    });
                  },
                  onEndChanged: (date) {
                    setState(() {
                      _dateRangeEnd = date;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 3. Working Hours
                WorkingHoursWidget(
                  startTime: _startTime,
                  endTime: _endTime,
                  onStartChanged: (time) {
                    setState(() {
                      _startTime = time;
                    });
                  },
                  onEndChanged: (time) {
                    setState(() {
                      _endTime = time;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 4. Off Days
                OffDaysSelectorWidget(
                  selectedOffDays: _offDays,
                  onChanged: (days) {
                    setState(() {
                      _offDays = days;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 5. Slot Duration
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Slot Duration / مدة الموعد',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _slotDuration > 15
                                  ? () => setState(() => _slotDuration -= 15)
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
                                '$_slotDuration min',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: _slotDuration < 120
                                  ? () => setState(() => _slotDuration += 15)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 32,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Preview
                Card(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.preview, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Preview / معاينة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PreviewItem(
                          label: 'Working days / أيام العمل',
                          value: '${_calculateWorkingDays()} days',
                        ),
                        _PreviewItem(
                          label: 'Slots per day / مواعيد باليوم',
                          value: '${_calculateSlotsPerDay()} slots',
                        ),
                        _PreviewItem(
                          label: 'Total slots / إجمالي المواعيد',
                          value: '${_calculateWorkingDays() * _calculateSlotsPerDay()} slots',
                          isHighlighted: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Last Generated Info
                if (_lastGenerated != null)
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Last Generated / آخر إنشاء',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy - hh:mm a')
                                      .format(_lastGenerated!),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Action Buttons
                PrimaryButton(
                  onPressed: _saveConfiguration,
                  text: 'Save Configuration / حفظ الإعدادات',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _generateSlots,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Generate Slots / إنشاء المواعيد'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _PreviewItem({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $label:',
            style: TextStyle(
              fontSize: isHighlighted ? 16 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
