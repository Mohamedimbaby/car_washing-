import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CentersSearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CentersSearchAppBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.navyDark,
      foregroundColor: AppColors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: _SearchBarBackground(
          controller: controller,
          onChanged: onChanged,
        ),
      ),
      title: const Text(
        'Find Car Wash Centers',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SearchBarBackground extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBarBackground({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyDark, AppColors.navyMedium],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search by name or location...',
          hintStyle: TextStyle(
            color: AppColors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.cyan),
          filled: true,
          fillColor: AppColors.white.withValues(alpha: 0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.white.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.cyan, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
