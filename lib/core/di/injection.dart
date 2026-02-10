import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/get_service_packages_usecase.dart';
import '../../features/booking/domain/usecases/create_booking_usecase.dart';
import '../../features/booking/domain/usecases/get_bookings_usecase.dart';
import '../../features/booking/domain/usecases/get_addons_usecase.dart';
import '../../features/booking/domain/usecases/get_time_slots_usecase.dart';
import '../../features/booking/presentation/cubit/booking_cubit.dart';
import '../../features/cars/data/repositories/car_repository_impl.dart';
import '../../features/cars/domain/repositories/car_repository.dart';
import '../../features/cars/domain/usecases/get_cars_usecase.dart';
import '../../features/cars/domain/usecases/add_car_usecase.dart';
import '../../features/cars/domain/usecases/update_car_usecase.dart';
import '../../features/cars/domain/usecases/delete_car_usecase.dart';
import '../../features/cars/presentation/cubit/car_cubit.dart';
import '../../features/provider/data/repositories/provider_repository_impl.dart';
import '../../features/provider/domain/repositories/provider_repository.dart';
import '../../features/provider/presentation/cubit/provider_cubit.dart';
import '../../features/packages/data/repositories/package_repository_impl.dart';
import '../../features/packages/domain/repositories/package_repository.dart';
import '../../features/packages/domain/usecases/get_packages_usecase.dart';
import '../../features/packages/domain/usecases/add_package_usecase.dart';
import '../../features/packages/domain/usecases/update_package_usecase.dart';
import '../../features/packages/domain/usecases/delete_package_usecase.dart';
import '../../features/packages/domain/usecases/toggle_package_status_usecase.dart';
import '../../features/packages/presentation/cubit/package_cubit.dart';
import '../../features/slots/data/repositories/slot_repository_impl.dart';
import '../../features/slots/data/repositories/schedule_repository_impl.dart';
import '../../features/slots/domain/repositories/slot_repository.dart';
import '../../features/slots/domain/repositories/schedule_repository.dart';
import '../../features/slots/domain/usecases/get_slots_usecase.dart';
import '../../features/slots/domain/usecases/add_slot_usecase.dart';
import '../../features/slots/domain/usecases/update_slot_usecase.dart';
import '../../features/slots/domain/usecases/delete_slot_usecase.dart';
import '../../features/slots/domain/usecases/add_bulk_slots_usecase.dart';
import '../../features/slots/domain/usecases/get_schedule_config_usecase.dart';
import '../../features/slots/domain/usecases/save_schedule_config_usecase.dart';
import '../../features/slots/domain/usecases/generate_monthly_slots_usecase.dart';
import '../../features/slots/domain/usecases/delete_schedule_config_usecase.dart';
import '../../features/slots/presentation/cubit/slot_cubit.dart';
import '../../features/slots/presentation/cubit/schedule_cubit.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import 'package:firebase_storage/firebase_storage.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );
  
  // Auth Feature
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      firestore: getIt(),
    ),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => AuthCubit(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    logoutUseCase: getIt(),
    authRepository: getIt(),
  ));

  // Booking Feature
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      firestore: getIt(),
      firebaseAuth: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => GetServicePackagesUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateBookingUseCase(getIt()));
  getIt.registerLazySingleton(() => GetBookingsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAddonsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTimeSlotsUseCase(getIt()));
  getIt.registerFactory(() => BookingCubit(
    getServicePackagesUseCase: getIt(),
    createBookingUseCase: getIt(),
    getBookingsUseCase: getIt(),
    getAddonsUseCase: getIt(),
    getTimeSlotsUseCase: getIt(),
  ));
  
  // Cars Feature
  getIt.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(
      firestore: getIt(),
      firebaseAuth: getIt(),
      storage: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => GetCarsUseCase(getIt()));
  getIt.registerLazySingleton(() => AddCarUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateCarUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCarUseCase(getIt()));
  getIt.registerFactory(() => CarCubit(
    getCarsUseCase: getIt(),
    addCarUseCase: getIt(),
    updateCarUseCase: getIt(),
    deleteCarUseCase: getIt(),
  ));
  
  // Provider Feature
  getIt.registerLazySingleton<ProviderRepository>(
    () => ProviderRepositoryImpl(
      firestore: getIt(),
      firebaseAuth: getIt(),
    ),
  );
  getIt.registerFactory(() => ProviderCubit(repository: getIt()));
  
  // Package Feature
  getIt.registerLazySingleton<PackageRepository>(
    () => PackageRepositoryImpl(
      firestore: getIt(),
      firebaseAuth: getIt(),
      storage: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => GetPackagesUseCase(getIt()));
  getIt.registerLazySingleton(() => AddPackageUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdatePackageUseCase(getIt()));
  getIt.registerLazySingleton(() => DeletePackageUseCase(getIt()));
  getIt.registerLazySingleton(() => TogglePackageStatusUseCase(getIt()));
  getIt.registerFactory(() => PackageCubit(
    getPackagesUseCase: getIt(),
    addPackageUseCase: getIt(),
    updatePackageUseCase: getIt(),
    deletePackageUseCase: getIt(),
    togglePackageStatusUseCase: getIt(),
  ));
  
  // Slot Feature
  getIt.registerLazySingleton<SlotRepository>(
    () => SlotRepositoryImpl(
      firestore: getIt(),
      firebaseAuth: getIt(),
    ),
  );
  getIt.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      firestore: getIt(),
      firebaseAuth: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => GetSlotsUseCase(getIt()));
  getIt.registerLazySingleton(() => AddSlotUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateSlotUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteSlotUseCase(getIt()));
  getIt.registerLazySingleton(() => AddBulkSlotsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetScheduleConfigUseCase(getIt<ScheduleRepository>()));
  getIt.registerLazySingleton(() => SaveScheduleConfigUseCase(getIt<ScheduleRepository>()));
  getIt.registerLazySingleton(() => GenerateMonthlySlotsUseCase(getIt<ScheduleRepository>()));
  getIt.registerLazySingleton(() => DeleteScheduleConfigUseCase(getIt<ScheduleRepository>()));
  getIt.registerFactory(() => SlotCubit(
    getSlotsUseCase: getIt(),
    addSlotUseCase: getIt(),
    updateSlotUseCase: getIt(),
    deleteSlotUseCase: getIt(),
    addBulkSlotsUseCase: getIt(),
  ));
  getIt.registerFactory(() => ScheduleCubit(
    getScheduleConfig: getIt(),
    saveScheduleConfig: getIt(),
    generateMonthlySlots: getIt(),
    deleteScheduleConfig: getIt(),
  ));
  
  // Profile Feature
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      firestore: getIt(),
      firebaseAuth: getIt(),
      storage: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => GetUserProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  getIt.registerFactory(() => ProfileCubit(
    getUserProfileUseCase: getIt(),
    updateProfileUseCase: getIt(),
  ));
}
