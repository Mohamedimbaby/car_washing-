import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/service_package_card.dart';

class ServiceSelectionPage extends StatefulWidget {
  final ServiceType serviceType;

  const ServiceSelectionPage({
    super.key,
    required this.serviceType,
  });

  @override
  State<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().loadServicePackages(widget.serviceType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceType == ServiceType.inCenter
              ? 'In-Center Wash'
              : 'On-Location Wash',
        ),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServicePackagesLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Package',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...state.packages.map(
                    (package) => ServicePackageCard(
                      package: package,
                      onSelect: () {
                        // Navigate to vehicle selection
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is BookingError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
