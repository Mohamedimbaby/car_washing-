import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/guest_mode_banner.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../widgets/service_type_card.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/quick_actions_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _startBooking(BuildContext context, ServiceType serviceType) {
    // For demo purposes, using mock IDs
    // In production, user would select vehicle and center first
    Navigator.pushNamed(
      context,
      AppRouter.packageSelection,
      arguments: {
        'serviceType': serviceType,
        'centerId': 'demo_center_001',
        'vehicleId': 'demo_vehicle_001',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HomeAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GuestModeBanner(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Service Type',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                    const SizedBox(height: 16),
                    ServiceTypeCard(
                      title: 'Wash at Center',
                      description: 'Book a time slot at our center',
                      icon: Icons.store,
                      color: AppColors.inCenterWash,
                      onTap: () {
                        _startBooking(context, ServiceType.inCenter);
                      },
                    ),
                    const SizedBox(height: 16),
                    ServiceTypeCard(
                      title: 'Wash at My Location',
                      description: 'We come to your location',
                      icon: Icons.location_on,
                      color: AppColors.onLocationWash,
                      onTap: () {
                        _startBooking(context, ServiceType.onLocation);
                      },
                    ),
                          const SizedBox(height: 32),
                          const QuickActionsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
