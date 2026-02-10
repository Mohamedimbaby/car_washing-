import 'package:flutter/material.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/theme/app_colors.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.business_center,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              const Text(
                'اختر نوع الحساب\nSelect Account Type',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر كيف تريد استخدام التطبيق\nChoose how you want to use the app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Customer Card
              _buildRoleCard(
                context,
                role: UserRole.customer,
                icon: Icons.person,
                title: 'عميل / Customer',
                description: 'احجز خدمات غسيل السيارات\nBook car wash services',
                color: AppColors.primary,
                onTap: () => Navigator.pop(context, UserRole.customer),
              ),
              const SizedBox(height: 16),

              // Service Provider Card
              _buildRoleCard(
                context,
                role: UserRole.serviceProvider,
                icon: Icons.store,
                title: 'مزود خدمة / Service Provider',
                description: 'قدم خدمات غسيل السيارات\nProvide car wash services',
                color: AppColors.secondary,
                onTap: () => Navigator.pop(context, UserRole.serviceProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
