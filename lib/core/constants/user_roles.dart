/// User role constants
class UserRoles {
  static const String customer = 'customer';
  static const String serviceProvider = 'service_provider';
  static const String admin = 'admin';
}

/// Enum for user roles
enum UserRole {
  customer,
  serviceProvider,
  admin;

  String get value {
    switch (this) {
      case UserRole.customer:
        return UserRoles.customer;
      case UserRole.serviceProvider:
        return UserRoles.serviceProvider;
      case UserRole.admin:
        return UserRoles.admin;
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case UserRoles.customer:
        return UserRole.customer;
      case UserRoles.serviceProvider:
        return UserRole.serviceProvider;
      case UserRoles.admin:
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}
