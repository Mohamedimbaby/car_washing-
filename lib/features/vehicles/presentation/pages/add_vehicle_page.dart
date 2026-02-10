import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../cubit/vehicle_cubit.dart';
import '../cubit/vehicle_state.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<VehicleCubit>().addVehicle(
            make: _makeController.text.trim(),
            model: _modelController.text.trim(),
            color: _colorController.text.trim(),
            licensePlate: _licensePlateController.text.trim(),
            year: int.parse(_yearController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
      ),
      body: BlocConsumer<VehicleCubit, VehicleState>(
        listener: (context, state) {
          if (state is VehicleAdded) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle added successfully')),
            );
          } else if (state is VehicleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is VehicleLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _makeController,
                    hintText: 'Make (e.g., Toyota)',
                    prefixIcon: Icons.directions_car,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle make';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _modelController,
                    hintText: 'Model (e.g., Camry)',
                    prefixIcon: Icons.car_rental,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle model';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _colorController,
                    hintText: 'Color (e.g., Red)',
                    prefixIcon: Icons.palette,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle color';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _licensePlateController,
                    hintText: 'License Plate',
                    prefixIcon: Icons.credit_card,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter license plate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _yearController,
                    hintText: 'Year (e.g., 2023)',
                    prefixIcon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle year';
                      }
                      final year = int.tryParse(value);
                      if (year == null || year < 1900 || year > 2030) {
                        return 'Please enter a valid year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Add Vehicle',
                    onPressed: _handleSubmit,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
