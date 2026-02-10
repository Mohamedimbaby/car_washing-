import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../cubit/package_cubit.dart';
import '../cubit/package_state.dart';

class AddPackagePage extends StatefulWidget {
  const AddPackagePage({super.key});

  @override
  State<AddPackagePage> createState() => _AddPackagePageState();
}

class _AddPackagePageState extends State<AddPackagePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  final List<String> _services = [];
  final _serviceController = TextEditingController();
  
  File? _imageFile;
  bool _isActive = true;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
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

  void _addService() {
    if (_serviceController.text.trim().isNotEmpty) {
      setState(() {
        _services.add(_serviceController.text.trim());
        _serviceController.clear();
      });
    }
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إضافة خدمة واحدة على الأقل / Please add at least one service'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<PackageCubit>().addPackage(
          name: _nameController.text.trim(),
          nameAr: _nameArController.text.trim(),
          description: _descriptionController.text.trim(),
          descriptionAr: _descriptionArController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          durationMinutes: int.parse(_durationController.text.trim()),
          services: _services,
          imageFile: _imageFile,
          isActive: _isActive,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة باقة / Add Package'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocListener<PackageCubit, PackageState>(
        listener: (context, state) {
          if (state is PackageAdded) {
            Navigator.pop(context);
          } else if (state is PackageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<PackageCubit, PackageState>(
          builder: (context, state) {
            final isLoading = state is PackageLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker (Optional)
                    _buildImagePicker(),
                    const SizedBox(height: 24),

                    // Package Name (English)
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Package Name (English)',
                      prefixIcon: Icons.inventory_2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Package Name (Arabic)
                    CustomTextField(
                      controller: _nameArController,
                      hintText: 'اسم الباقة (عربي) / Package Name (Arabic)',
                      prefixIcon: Icons.inventory_2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description (English)
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Description (English)',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description (Arabic)
                    CustomTextField(
                      controller: _descriptionArController,
                      hintText: 'الوصف (عربي) / Description (Arabic)',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price
                    CustomTextField(
                      controller: _priceController,
                      hintText: 'السعر (جنيه) / Price (EGP)',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'سعر غير صحيح / Invalid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    CustomTextField(
                      controller: _durationController,
                      hintText: 'المدة (دقيقة) / Duration (minutes)',
                      prefixIcon: Icons.access_time,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب / Required';
                        }
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'مدة غير صحيحة / Invalid duration';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Services Section
                    _buildServicesSection(),
                    const SizedBox(height: 16),

                    // Is Active Toggle
                    SwitchListTile(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      title: const Text('باقة نشطة / Active Package'),
                      subtitle: const Text('يمكن للعملاء رؤيتها وحجزها'),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    PrimaryButton(
                      text: 'إضافة الباقة / Add Package',
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
          'صورة الباقة (اختياري) / Package Image (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            child: _imageFile != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.error,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, color: AppColors.white, size: 16),
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
                        size: 40,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'انقر لإضافة صورة\nClick to add image',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الخدمات المشمولة / Services Included *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        // Add Service Field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _serviceController,
                decoration: const InputDecoration(
                  hintText: 'أضف خدمة / Add service',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_circle_outline),
                ),
                onSubmitted: (_) => _addService(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addService,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Icon(Icons.add, color: AppColors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Services List
        if (_services.isNotEmpty)
          ...List.generate(_services.length, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.success),
                title: Text(_services[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _removeService(index),
                ),
              ),
            );
          }),
      ],
    );
  }
}
