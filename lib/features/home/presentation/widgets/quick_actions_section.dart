import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'quick_action_button.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child:         QuickActionButton(
          icon: Icons.history,
          label: 'My Bookings',
          onTap: () {
            Navigator.pushNamed(context, '/booking-history');
          },
        ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:         QuickActionButton(
          icon: Icons.directions_car,
          label: 'مركباتي / My Cars',
          onTap: () {
            Navigator.pushNamed(context, '/my-cars');
          },
        ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.search,
                label: 'Find Centers',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.person,
                label: 'Profile',
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
