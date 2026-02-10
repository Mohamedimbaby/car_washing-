import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/booking/presentation/pages/package_selection_page.dart';
import '../../features/booking/presentation/pages/addon_selection_page.dart';
import '../../features/booking/presentation/pages/time_slot_selection_page.dart';
import '../../features/booking/presentation/pages/booking_success_page.dart';
import '../../features/booking/presentation/pages/booking_history_page.dart';
import '../../features/booking/domain/entities/booking_entity.dart';
import '../../features/booking/domain/entities/service_package_entity.dart';
import '../../features/cars/presentation/pages/my_cars_page.dart';
import '../../features/cars/presentation/pages/add_car_page.dart';
import '../../features/provider/presentation/pages/provider_dashboard_page.dart';
import '../../features/packages/presentation/pages/my_packages_page.dart';
import '../../features/packages/presentation/pages/add_package_page.dart';
import '../../features/slots/presentation/pages/my_slots_page.dart';
import '../../features/slots/presentation/pages/add_slot_page.dart';
import '../../features/slots/presentation/pages/add_bulk_slots_page.dart';
import '../../features/provider/presentation/pages/provider_bookings_page.dart';
import '../../features/provider/presentation/pages/provider_customers_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/domain/entities/user_profile_entity.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String packageSelection = '/package-selection';
  static const String addonSelection = '/addon-selection';
  static const String timeSlotSelection = '/time-slot-selection';
  static const String bookingSuccess = '/booking-success';
  static const String bookingHistory = '/booking-history';
  static const String profile = '/profile';
  static const String vehicles = '/vehicles';
  static const String centerDetails = '/center-details';
  static const String search = '/search';
  static const String providerDashboard = '/provider-dashboard';
  static const String tenantManagement = '/tenant-management';
  static const String myCars = '/my-cars';
  static const String addCar = '/add-car';
  static const String editCar = '/edit-car';
  static const String myPackages = '/my-packages';
  static const String addPackage = '/add-package';
  static const String editPackage = '/edit-package';
  static const String mySlots = '/my-slots';
  static const String addSlot = '/add-slot';
  static const String addBulkSlots = '/add-bulk-slots';
  static const String providerBookings = '/provider-bookings';
  static const String providerCustomers = '/provider-customers';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case packageSelection:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PackageSelectionPage(
            serviceType: args['serviceType'] as ServiceType,
            centerId: args['centerId'] as String,
            vehicleId: args['vehicleId'] as String,
          ),
        );
      case addonSelection:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddonSelectionPage(
            package: args['package'] as ServicePackageEntity,
            serviceType: args['serviceType'] as ServiceType,
            centerId: args['centerId'] as String,
            vehicleId: args['vehicleId'] as String,
          ),
        );
      case timeSlotSelection:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TimeSlotSelectionPage(
            package: args['package'] as ServicePackageEntity,
            serviceType: args['serviceType'] as ServiceType,
            centerId: args['centerId'] as String,
            vehicleId: args['vehicleId'] as String,
            addonIds: args['addonIds'] as List<String>,
          ),
        );
      case bookingSuccess:
        return MaterialPageRoute(builder: (_) => const BookingSuccessPage());
      case bookingHistory:
        return MaterialPageRoute(builder: (_) => const BookingHistoryPage());
      case myCars:
        return MaterialPageRoute(builder: (_) => const MyCarsPage());
      case addCar:
        return MaterialPageRoute(builder: (_) => const AddCarPage());
      case editCar:
        final carId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => const AddCarPage(), // Will create EditCarPage later
        );
      case providerDashboard:
        return MaterialPageRoute(builder: (_) => const ProviderDashboardPage());
      case myPackages:
        return MaterialPageRoute(builder: (_) => const MyPackagesPage());
      case addPackage:
        return MaterialPageRoute(builder: (_) => const AddPackagePage());
      case editPackage:
        final packageId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => const AddPackagePage(), // Will create EditPackagePage later
        );
      case mySlots:
        return MaterialPageRoute(builder: (_) => const MySlotsPage());
      case addSlot:
        return MaterialPageRoute(builder: (_) => const AddSlotPage());
      case addBulkSlots:
        return MaterialPageRoute(builder: (_) => const AddBulkSlotsPage());
      case providerBookings:
        return MaterialPageRoute(builder: (_) => const ProviderBookingsPage());
      case providerCustomers:
        return MaterialPageRoute(builder: (_) => const ProviderCustomersPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case editProfile:
        final profile = settings.arguments as UserProfileEntity;
        return MaterialPageRoute(
          builder: (_) => EditProfilePage(profile: profile),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
