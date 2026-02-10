import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/service_package_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/package_card.dart';

class PackageSelectionPage extends StatefulWidget {
  final ServiceType serviceType;
  final String centerId;
  final String vehicleId;

  const PackageSelectionPage({
    super.key,
    required this.serviceType,
    required this.centerId,
    required this.vehicleId,
  });

  @override
  State<PackageSelectionPage> createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().loadServicePackages(widget.serviceType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Package'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<BookingCubit>()
                        .loadServicePackages(widget.serviceType),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ServicePackagesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.packages.length,
              itemBuilder: (context, index) {
                final package = state.packages[index];
                return PackageCard(
                  package: package,
                  onTap: () => _navigateToAddonSelection(package),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToAddonSelection(ServicePackageEntity package) {
    context.read<BookingCubit>().loadAddons();
    Navigator.pushNamed(
      context,
      '/addon-selection',
      arguments: {
        'package': package,
        'serviceType': widget.serviceType,
        'centerId': widget.centerId,
        'vehicleId': widget.vehicleId,
      },
    );
  }
}
