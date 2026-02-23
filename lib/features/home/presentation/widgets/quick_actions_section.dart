import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'quick_action_button.dart';
import 'section_header_widget.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeaderWidget(title: 'Quick Actions'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: Icons.history_rounded,
                  label: 'My Bookings',
                  iconColor: AppColors.navyMedium,
                  onTap: () =>
                      Navigator.pushNamed(context, '/booking-history'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.directions_car_rounded,
                  label: 'My Cars',
                  iconColor: AppColors.cyanDark,
                  onTap: () => Navigator.pushNamed(context, '/my-cars'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.search_rounded,
                  label: 'Centers',
                  iconColor: AppColors.success,
                  onTap: () =>
                      Navigator.pushNamed(context, '/search-centers'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  iconColor: AppColors.gold,
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
