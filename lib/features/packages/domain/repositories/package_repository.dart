import 'dart:io';
import '../../../../core/utils/typedef.dart';
import '../entities/package_entity.dart';

abstract class PackageRepository {
  /// Get all packages for current provider
  ResultFuture<List<PackageEntity>> getPackages();

  /// Get package by ID
  ResultFuture<PackageEntity> getPackageById(String packageId);

  /// Add new package
  ResultFuture<PackageEntity> addPackage({
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required int durationMinutes,
    required List<String> services,
    File? imageFile,
    bool isActive,
  });

  /// Update existing package
  ResultFuture<PackageEntity> updatePackage({
    required String packageId,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    int? durationMinutes,
    List<String>? services,
    File? imageFile,
    bool? isActive,
  });

  /// Delete package
  ResultVoid deletePackage(String packageId);

  /// Toggle package active status
  ResultVoid togglePackageStatus(String packageId, bool isActive);

  /// Get booking count for a package
  ResultFuture<int> getPackageBookingCount(String packageId);
}
