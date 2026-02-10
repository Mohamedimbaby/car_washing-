import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/package_cubit.dart';
import '../cubit/package_state.dart';
import '../widgets/package_card_widget.dart';

class MyPackagesPage extends StatefulWidget {
  const MyPackagesPage({super.key});

  @override
  State<MyPackagesPage> createState() => _MyPackagesPageState();
}

class _MyPackagesPageState extends State<MyPackagesPage> {
  @override
  void initState() {
    super.initState();
    context.read<PackageCubit>().loadPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('باقاتي / My Packages'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<PackageCubit, PackageState>(
        listener: (context, state) {
          if (state is PackageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is PackageAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت إضافة الباقة / Package added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is PackageDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف الباقة / Package deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PackageLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PackagesLoaded) {
            if (state.packages.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PackageCubit>().loadPackages();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.packages.length,
                itemBuilder: (context, index) {
                  final package = state.packages[index];
                  return PackageCardWidget(
                    package: package,
                    onTap: () => _navigateToEditPackage(package.id),
                    onToggleStatus: (isActive) {
                      context.read<PackageCubit>().toggleStatus(
                            package.id,
                            isActive,
                          );
                    },
                    onDelete: () => _confirmDelete(context, package.id),
                  );
                },
              ),
            );
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddPackage(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('إضافة باقة / Add Package'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد باقات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No packages yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddPackage(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة باقة الأولى / Add Your First Package'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddPackage() {
    Navigator.pushNamed(context, AppRouter.addPackage);
  }

  void _navigateToEditPackage(String packageId) {
    Navigator.pushNamed(
      context,
      AppRouter.editPackage,
      arguments: packageId,
    );
  }

  Future<void> _confirmDelete(BuildContext context, String packageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الباقة / Delete Package'),
        content: const Text(
          'هل أنت متأكد من حذف هذه الباقة؟\nAre you sure you want to delete this package?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء / Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف / Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<PackageCubit>().deletePackage(packageId);
    }
  }
}
