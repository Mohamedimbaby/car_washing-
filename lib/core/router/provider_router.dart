import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/provider/presentation/pages/provider_dashboard_page.dart';
import '../../features/packages/presentation/pages/my_packages_page.dart';
import '../../features/packages/presentation/pages/add_package_page.dart';
import '../../features/slots/presentation/pages/my_slots_page.dart';
import '../../features/slots/presentation/pages/add_slot_page.dart';
import '../../features/slots/presentation/pages/add_bulk_slots_page.dart';
import '../../features/slots/presentation/pages/schedule_config_page.dart';
import '../../features/provider/presentation/pages/provider_bookings_page.dart';
import '../../features/provider/presentation/pages/provider_customers_page.dart';
import '../../features/provider/presentation/pages/customer_details_page.dart';
import '../../features/provider/domain/entities/customer_entity.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';

class ProviderRouter {
  // Provider App Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/';
  static const String myPackages = '/my-packages';
  static const String addPackage = '/add-package';
  static const String editPackage = '/edit-package';
  static const String mySlots = '/my-slots';
  static const String addSlot = '/add-slot';
  static const String addBulkSlots = '/add-bulk-slots';
  static const String scheduleConfig = '/schedule-config';
  static const String myBookings = '/my-bookings';
  static const String myCustomers = '/my-customers';
  static const String customerDetails = '/customer-details';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      
      case dashboard:
        return MaterialPageRoute(builder: (_) => const ProviderDashboardPage());
      
      case myPackages:
        return MaterialPageRoute(builder: (_) => const MyPackagesPage());
      
      case addPackage:
        return MaterialPageRoute(builder: (_) => const AddPackagePage());
      
      case editPackage:
        // final package = settings.arguments as PackageEntity?;
        return MaterialPageRoute(
          builder: (_) => const AddPackagePage(),
        );
      
      case mySlots:
        return MaterialPageRoute(builder: (_) => const MySlotsPage());
      
      case addSlot:
        return MaterialPageRoute(builder: (_) => const AddSlotPage());
      
      case addBulkSlots:
        return MaterialPageRoute(builder: (_) => const AddBulkSlotsPage());
      
      case scheduleConfig:
        return MaterialPageRoute(builder: (_) => const ScheduleConfigPage());
      
      case myBookings:
        return MaterialPageRoute(builder: (_) => const ProviderBookingsPage());
      
      case myCustomers:
        return MaterialPageRoute(builder: (_) => const ProviderCustomersPage());
      
      case customerDetails:
        final customer = settings.arguments as CustomerEntity;
        return MaterialPageRoute(
          builder: (_) => CustomerDetailsPage(
            customer: customer,
          ),
        );
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      
      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfilePage(),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('404 - Page Not Found'),
            ),
          ),
        );
    }
  }
}
