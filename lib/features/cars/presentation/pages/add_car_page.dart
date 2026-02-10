import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../cubit/car_cubit.dart';
import '../cubit/car_state.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();

  File? _imageFile;
  bool _isDefault = false;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض / Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة / Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار صورة للمركبة / Please select a car image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<CarCubit>().addCar(
          plateNumber: _plateController.text.trim(),
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          color: _colorController.text.trim(),
          year: int.parse(_yearController.text.trim()),
          imageFile: _imageFile!,
          isDefault: _isDefault,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مركبة / Add Car'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocListener<CarCubit, CarState>(
        listener: (context, state) {
          if (state is CarAdded) {
            Navigator.pop(context);
          } else if (state is CarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<CarCubit, CarState>(
          builder: (context, state) {
            final isLoading = state is CarLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker
                    _buildImagePicker(),
                    const SizedBox(height: 24),

                    // Plate Number
                    CustomTextField(
                      controller: _plateController,
                      hintText: 'رقم اللوحة / License Plate Number',
                      prefixIcon: Icons.confirmation_number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Brand
                    CustomTextField(
                      controller: _brandController,
                      hintText: 'ماركة السيارة / Car Brand',
                      prefixIcon: Icons.directions_car,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Model
                    CustomTextField(
                      controller: _modelController,
                      hintText: 'الموديل / Model',
                      prefixIcon: Icons.car_repair,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Color
                    CustomTextField(
                      controller: _colorController,
                      hintText: 'اللون / Color',
                      prefixIcon: Icons.palette,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Year
                    CustomTextField(
                      controller: _yearController,
                      hintText: 'السنة / Year',
                      prefixIcon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                          return 'سنة غير صحيحة / Invalid year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Set as Default
                    CheckboxListTile(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() => _isDefault = value ?? false);
                      },
                      title: const Text('جعلها مركبة افتراضية / Set as Default Car'),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    PrimaryButton(
                      text: 'إضافة / Add Car',
                      onPressed: _handleSubmit,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صورة المركبة / Car Image *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _showImageSourceDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            child: _imageFile != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: AppColors.error,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: AppColors.white),
                            onPressed: () {
                              setState(() => _imageFile = null);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'انقر لإضافة صورة\nClick to add image',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
