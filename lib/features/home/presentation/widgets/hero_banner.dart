import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'hero_background.dart';
import 'hero_greeting_row.dart';
import 'hero_content_widget.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyDark, AppColors.navyMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Stack(
        children: [
          HeroBackground(),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroGreetingRow(),
                SizedBox(height: 20),
                HeroContentWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
