import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/service_package_entity.dart';
import '../../domain/entities/addon_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../../../auth/presentation/widgets/primary_button.dart';

class AddonSelectionPage extends StatefulWidget {
  final ServicePackageEntity package;
  final ServiceType serviceType;
  final String centerId;
  final String vehicleId;

  const AddonSelectionPage({
    super.key,
    required this.package,
    required this.serviceType,
    required this.centerId,
    required this.vehicleId,
  });

  @override
  State<AddonSelectionPage> createState() => _AddonSelectionPageState();
}

class _AddonSelectionPageState extends State<AddonSelectionPage> {
  final Set<String> selectedAddonIds = {};

  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().loadAddons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add-ons'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddonsLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPackageSummary(),
                      const SizedBox(height: 24),
                      const Text(
                        'Optional Add-ons',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.addons.map((addon) => _buildAddonTile(addon)),
                    ],
                  ),
                ),
                _buildBottomBar(state.addons),
              ],
            );
          }

          return const Center(child: Text('No add-ons available'));
        },
      ),
    );
  }

  Widget _buildPackageSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.package.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '~${widget.package.durationMinutes} minutes',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            Text(
              '\$${widget.package.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonTile(AddonEntity addon) {
    final isSelected = selectedAddonIds.contains(addon.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              selectedAddonIds.add(addon.id);
            } else {
              selectedAddonIds.remove(addon.id);
            }
          });
        },
        title: Text(
          addon.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(addon.description),
        secondary: Text(
          '+\$${addon.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBottomBar(List<AddonEntity> allAddons) {
    final selectedAddons = allAddons
        .where((addon) => selectedAddonIds.contains(addon.id))
        .toList();
    final addonTotal = selectedAddons.fold<double>(
      0,
      (sum, addon) => sum + addon.price,
    );
    final total = widget.package.price + addonTotal;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Continue',
              onPressed: () => _navigateToTimeSlot(),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTimeSlot() {
    Navigator.pushNamed(
      context,
      '/time-slot-selection',
      arguments: {
        'package': widget.package,
        'serviceType': widget.serviceType,
        'centerId': widget.centerId,
        'vehicleId': widget.vehicleId,
        'addonIds': selectedAddonIds.toList(),
      },
    );
  }
}
