import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/car_cubit.dart';
import '../cubit/car_state.dart';
import '../widgets/car_card.dart';

class MyCarsPage extends StatefulWidget {
  const MyCarsPage({super.key});

  @override
  State<MyCarsPage> createState() => _MyCarsPageState();
}

class _MyCarsPageState extends State<MyCarsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CarCubit>().loadCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مركباتي / My Cars'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<CarCubit, CarState>(
        listener: (context, state) {
          if (state is CarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is CarAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Car added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is CarDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Car deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CarsLoaded) {
            if (state.cars.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CarCubit>().loadCars();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.cars.length,
                itemBuilder: (context, index) {
                  final car = state.cars[index];
                  return CarCard(
                    car: car,
                    onTap: () => _navigateToEditCar(car.id),
                    onDelete: () => _confirmDelete(context, car.id),
                    onSetDefault: () => _setDefaultCar(context, car.id),
                  );
                },
              ),
            );
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddCar(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مركبة / Add Car'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد مركبات مسجلة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No cars registered yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddCar(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة مركبة الأولى / Add Your First Car'),
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

  void _navigateToAddCar() {
    Navigator.pushNamed(context, AppRouter.addCar);
  }

  void _navigateToEditCar(String carId) {
    Navigator.pushNamed(
      context,
      AppRouter.editCar,
      arguments: carId,
    );
  }

  void _setDefaultCar(BuildContext context, String carId) {
    // Implementation would use CarRepository's setDefaultCar
    context.read<CarCubit>().loadCars();
  }

  Future<void> _confirmDelete(BuildContext context, String carId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المركبة / Delete Car'),
        content: const Text(
          'هل أنت متأكد من حذف هذه المركبة؟\nAre you sure you want to delete this car?',
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
      context.read<CarCubit>().deleteCar(carId);
    }
  }
}
