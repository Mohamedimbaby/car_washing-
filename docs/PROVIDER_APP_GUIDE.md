# Service Provider App Guide

## 🏢 Overview

The Service Provider Admin App allows car wash center owners and managers to manage their business operations, bookings, staff, and analytics.

## 🚀 How to Run

### Option 1: Separate Entry Point (Recommended for Development)

Run the provider app directly:

```bash
cd /Users/imbaby/Desktop/Washing-Cars/washing_car

# Run provider app
flutter run -t lib/main_provider.dart
```

This launches directly into the provider dashboard.

### Option 2: Role Selection (Recommended for Production)

Add role selection to the main app router to allow users to choose their role at launch.

### Option 3: From Within Customer App

Access provider features through profile or settings (when implemented).

## 📱 Provider App Features

### 1. Dashboard
**Location**: `lib/features/provider/presentation/pages/provider_dashboard_page.dart`

**Features:**
- Today's booking statistics
- Revenue tracking
- Pending bookings count
- Completed bookings count
- Quick action buttons
- Recent bookings list

**Access:** Direct entry point via `main_provider.dart`

### 2. Booking Management
**Features:**
- View all bookings (pending, ongoing, completed)
- Accept/reject booking requests
- Assign bookings to staff or bays
- Update booking status
- Add service notes
- Upload before/after photos

**UI Components:**
- Booking list with filters
- Status update controls
- Staff assignment dropdown
- Photo upload functionality

### 3. Staff Management
**Features:**
- Add team members with roles:
  - Manager
  - Washer
  - Mobile Service Tech
- Assign staff to branches
- Track staff schedules
- Performance metrics

**Domain:** `lib/features/provider/domain/entities/staff_entity.dart`

### 4. Business Profile
**Features:**
- Center information
- Service offerings configuration
- Operating hours
- Photo gallery
- Multi-branch management

### 5. Analytics & Reports
**Features:**
- Booking statistics
- Revenue trends
- Popular services analysis
- Customer retention metrics
- Peak hours/days tracking

**Entity:** `lib/features/provider/domain/entities/booking_stats_entity.dart`

## 🎨 UI Components

### Stats Cards
**Location**: `lib/features/provider/presentation/widgets/stats_card.dart`

Displays key metrics:
- Bookings count
- Revenue
- Pending items
- Completed items

### Quick Actions
**Location**: `lib/features/provider/presentation/widgets/quick_actions_provider.dart`

Grid of action buttons:
- Bookings
- Staff
- Reports

### Recent Bookings
**Location**: `lib/features/provider/presentation/widgets/recent_bookings_section.dart`

Shows latest booking activity.

## 🏗️ Architecture

The provider app follows the same clean architecture:

```
lib/features/provider/
├── domain/
│   ├── entities/
│   │   ├── staff_entity.dart
│   │   └── booking_stats_entity.dart
│   └── repositories/
│       └── provider_repository.dart
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── cubit/
    ├── pages/
    │   └── provider_dashboard_page.dart
    └── widgets/
        ├── stats_card.dart
        ├── quick_actions_provider.dart
        └── recent_bookings_section.dart
```

## 🔧 Configuration

### 1. Set Provider API Endpoints

```dart
// In lib/core/network/dio_client.dart
static const String baseUrl = 'https://api.carwash.com/v1';

// Provider-specific endpoints:
// GET  /provider/dashboard
// GET  /provider/bookings
// POST /provider/bookings/{id}/accept
// GET  /provider/staff
// POST /provider/staff
```

### 2. Add Provider Authentication

The provider app needs separate authentication:

```dart
// Provider login endpoint
POST /provider/auth/login
{
  "email": "provider@center.com",
  "password": "password",
  "role": "provider"
}
```

### 3. Role-Based Access Control

Add role checking:

```dart
enum UserRole { customer, provider, admin }

class UserEntity {
  final String id;
  final UserRole role;
  // ...
}
```

## 🎯 Running Different Modes

### Development Mode

**Customer App:**
```bash
flutter run
# or
flutter run -t lib/main.dart
```

**Provider App:**
```bash
flutter run -t lib/main_provider.dart
```

**Admin App:**
```bash
flutter run -t lib/main_admin.dart  # Create this
```

### Production Mode

Use single app with role-based routing:

```dart
// After authentication
if (user.role == UserRole.provider) {
  Navigator.pushReplacementNamed(context, '/provider-dashboard');
} else if (user.role == UserRole.customer) {
  Navigator.pushReplacementNamed(context, '/home');
} else if (user.role == UserRole.admin) {
  Navigator.pushReplacementNamed(context, '/admin-dashboard');
}
```

## 🧪 Testing Provider App

### 1. Quick Test (No Backend)

```bash
# Run provider app
flutter run -t lib/main_provider.dart

# You'll see:
# - Dashboard with sample stats
# - Quick action buttons
# - Recent bookings section
```

### 2. With Mock Data

Add mock data for testing:

```dart
// In provider_dashboard_page.dart
final mockStats = BookingStatsEntity(
  totalBookings: 150,
  pendingBookings: 5,
  confirmedBookings: 10,
  completedBookings: 130,
  cancelledBookings: 5,
  totalRevenue: 15000.00,
  todayRevenue: 1250.00,
  monthRevenue: 12500.00,
);
```

### 3. Guest Mode for Provider

Add provider guest mode:

```dart
class ProviderGuestMode extends AuthState {}

Future<void> continueAsProviderGuest() async {
  await authRepository.saveToken('PROVIDER_GUEST_MODE');
  emit(ProviderGuestMode());
}
```

## 📊 Provider Dashboard Screens

### Main Dashboard
- **Path:** `/provider-dashboard`
- **Shows:** Stats overview, quick actions, recent bookings
- **Access:** Home screen after provider login

### Bookings List
- **Path:** `/provider/bookings`
- **Shows:** All bookings with filters
- **Actions:** Accept, reject, update status

### Staff Management
- **Path:** `/provider/staff`
- **Shows:** Team members list
- **Actions:** Add, edit, delete staff

### Analytics
- **Path:** `/provider/analytics`
- **Shows:** Charts, graphs, trends
- **Filters:** Date range, service type, branch

### Profile Settings
- **Path:** `/provider/settings`
- **Shows:** Center info, services, hours
- **Actions:** Update profile, manage branches

## 🎨 Customization

### Change Dashboard Layout

Edit `provider_dashboard_page.dart`:

```dart
// Modify stats grid
Row(
  children: [
    Expanded(child: StatsCard(...)),
    Expanded(child: StatsCard(...)),
  ],
)
```

### Add New Stats Card

```dart
StatsCard(
  title: 'New Metric',
  value: '42',
  icon: Icons.trending_up,
  color: AppColors.info,
)
```

### Custom Quick Actions

Edit `quick_actions_provider.dart`:

```dart
_buildActionButton(
  'New Action',
  Icons.new_icon,
  AppColors.primary,
)
```

## 🔐 Security

### Provider-Only Features

Protect provider routes:

```dart
// Route guard
if (user.role != UserRole.provider) {
  return Unauthorized();
}
```

### API Authentication

```dart
// Add provider token
headers['X-Provider-Id'] = providerId;
headers['Authorization'] = 'Bearer $providerToken';
```

## 📝 Next Steps

1. **Create Provider Login:**
   - Add provider-specific login screen
   - Implement role-based authentication

2. **Connect to Backend:**
   - Update API endpoints
   - Implement provider repository
   - Add provider use cases

3. **Add Real Booking Management:**
   - Fetch real bookings from API
   - Implement status updates
   - Add staff assignment

4. **Build Analytics:**
   - Create charts with fl_chart package
   - Add date filters
   - Implement export functionality

5. **Multi-Branch Support:**
   - Branch switcher
   - Per-branch analytics
   - Branch-specific staff

## 🎯 Quick Commands

```bash
# Run customer app (default)
flutter run

# Run provider app
flutter run -t lib/main_provider.dart

# Build provider APK
flutter build apk -t lib/main_provider.dart

# Build provider iOS
flutter build ios -t lib/main_provider.dart
```

## 📱 Provider App Screenshots Flow

1. **Launch** → Provider Dashboard
2. **See Stats** → Today's bookings, revenue
3. **Quick Actions** → Tap "Bookings"
4. **Booking List** → See all bookings
5. **Booking Details** → Accept/Reject, assign staff
6. **Update Status** → In Progress → Completed

## ✨ Summary

The Service Provider App is ready! Just run:

```bash
flutter run -t lib/main_provider.dart
```

And explore the provider dashboard with:
- 📊 Stats overview
- ⚡ Quick actions
- 📋 Recent bookings
- 🎨 Beautiful UI

Perfect for car wash center owners to manage their business! 🚗✨
