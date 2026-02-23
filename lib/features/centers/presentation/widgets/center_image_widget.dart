import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CenterImageWidget extends StatelessWidget {
  const CenterImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyDark, AppColors.navyMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: const Icon(
        Icons.local_car_wash,
        color: Colors.white24,
        size: 44,
      ),
    );
  }
}
