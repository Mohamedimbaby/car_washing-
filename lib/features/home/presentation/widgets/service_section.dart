import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../../core/router/app_router.dart';
import 'section_header_widget.dart';
import 'service_type_card.dart';

class ServiceSection extends StatelessWidget {
  const ServiceSection({super.key});

  void _startBooking(BuildContext context, ServiceType serviceType) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeaderWidget(title: 'Choose a Service'),
          const SizedBox(height: 14),
          ServiceTypeCard(
            title: 'Wash at Center',
            description: 'Drive in, relax & let us handle it',
            icon: Icons.store_rounded,
            gradientColors: const [AppColors.navy, AppColors.navyLight],
            onTap: () => _startBooking(context, ServiceType.inCenter),
          ),
          const SizedBox(height: 12),
          ServiceTypeCard(
            title: 'Wash at My Location',
            description: 'Our mobile team comes to you',
            icon: Icons.directions_car_rounded,
            gradientColors: const [AppColors.cyanDark, AppColors.cyan],
            onTap: () => _startBooking(context, ServiceType.onLocation),
          ),
        ],
      ),
    );
  }
}
