# Guest Mode Guide

## 🎯 What is Guest Mode?

Guest Mode allows users to explore the app without creating an account or connecting to APIs. Perfect for:
- Development and testing
- Demos and presentations
- Allowing users to browse before signing up

## ✨ Features

### Current Implementation

1. **"Continue as Guest" Button**
   - Available on the login screen
   - One-tap access to the app
   - No authentication required

2. **Guest Mode Indicator**
   - "GUEST" badge on home screen
   - Clear visual indicator of guest status
   - "Browse as Guest" welcome message

3. **Guest Mode Banner**
   - Prominent banner on home page
   - Quick "Login" button for easy conversion
   - Explains benefits of signing in

4. **Persistent Guest Session**
   - Guest mode saved locally
   - Survives app restarts
   - Can be cleared by logging out

### User Flow

```
App Launch → Splash Screen
    ↓
Check Auth Status
    ↓
No Auth? → Login Screen
    ↓
[Continue as Guest] → Home Screen (Guest Mode)
    ↓
Browse app freely
    ↓
Click "Login" when ready → Login Screen
```

## 🔧 Technical Implementation

### State Management

```dart
// New state added to AuthState
class GuestMode extends AuthState {}

// Cubit method
Future<void> continueAsGuest() async {
  emit(AuthLoading());
  await authRepository.saveToken('GUEST_MODE');
  emit(GuestMode());
}
```

### Storage

Guest mode is stored using the token system:
- Token value: `'GUEST_MODE'`
- Storage: `SharedPreferences`
- Key: `'AUTH_TOKEN'`

### Detection

```dart
// In checkAuthStatus()
final token = await authRepository.getToken();
if (token == 'GUEST_MODE') {
  emit(GuestMode());
  return;
}
```

## 🎨 UI Components

### 1. Login Page
- Added "Continue as Guest" button
- Icon: `Icons.person_outline`
- Positioned between login and sign-up

### 2. Home App Bar
- Shows "Guest" as username
- "GUEST" badge displayed
- Changes welcome message

### 3. Guest Mode Banner
- Full-width banner on home page
- Gradient background
- Quick login button
- Auto-hides when authenticated

## 🚀 Testing Guest Mode

### Manual Testing

1. **Clean Install:**
   ```bash
   flutter clean
   flutter run
   ```

2. **First Launch:**
   - Should show splash → login
   - Tap "Continue as Guest"
   - Should navigate to home with guest banner

3. **App Restart:**
   - Close and reopen app
   - Should automatically show home (guest mode persists)

4. **Login from Guest:**
   - Tap "Login" on banner
   - Enter credentials
   - Should authenticate and remove guest indicator

5. **Logout:**
   - Logout from app
   - Should return to login screen
   - Guest mode cleared

## 📱 When to Use Guest Mode

### ✅ Good Use Cases
- **Development**: Test UI without backend
- **Demos**: Show app functionality
- **User onboarding**: Let users explore first
- **Offline mode**: Browse cached content

### ❌ Limitations
- Cannot save data permanently
- No personalization
- Limited features (booking, payments)
- No sync across devices

## 🔐 Security Considerations

### Safe
- ✅ No real user data
- ✅ Local storage only
- ✅ Can't access protected endpoints
- ✅ Easy to clear/reset

### To Implement (Future)
- [ ] Session expiry for guest mode
- [ ] Anonymous analytics
- [ ] Feature restrictions
- [ ] Data migration when converting to user

## 🎯 Converting Guest to User

### Current Flow
```dart
// User clicks "Login" on banner
await context.read<AuthCubit>().logout(); // Clears guest mode
Navigator.pushReplacementNamed(AppRouter.login);
```

### Future Enhancement Ideas

1. **Data Migration:**
   ```dart
   // Save guest data before login
   final guestData = await saveGuestData();
   // After login
   await migrateGuestDataToUser(guestData);
   ```

2. **One-Tap Conversion:**
   - Quick signup from guest mode
   - Pre-fill user preferences
   - Transfer viewing history

3. **Incentives:**
   - "Sign up now and get 10% off"
   - "Save your favorite centers"
   - "Get booking reminders"

## 🛠️ Customization

### Change Guest User Name

```dart
// In home_app_bar.dart
String userName = 'Guest'; // Change this
```

### Modify Guest Banner Message

```dart
// In guest_mode_banner.dart
Text('Your custom message here')
```

### Hide Guest Banner

```dart
// In home_page.dart
// Comment out or remove:
// const GuestModeBanner(),
```

### Add Guest Mode Restrictions

```dart
// Example: Restrict booking feature
if (state is GuestMode) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Please login to book services')),
  );
  return;
}
// Proceed with booking...
```

## 📊 Analytics (Future)

Track guest mode usage:
```dart
// Log guest mode events
analytics.logEvent(
  name: 'guest_mode_started',
  parameters: {'timestamp': DateTime.now()},
);

analytics.logEvent(
  name: 'guest_converted_to_user',
  parameters: {'duration_minutes': sessionDuration},
);
```

## 🐛 Troubleshooting

### Guest Mode Not Persisting
**Issue**: Guest mode resets on app restart

**Solution**: Check token storage
```dart
final token = await authRepository.getToken();
print('Stored token: $token'); // Should be 'GUEST_MODE'
```

### Cannot Exit Guest Mode
**Issue**: Stuck in guest mode after logout

**Solution**: Clear shared preferences
```bash
flutter clean
flutter run
```

### Guest Banner Always Shows
**Issue**: Banner shows even when authenticated

**Solution**: Check state handling in `GuestModeBanner`
```dart
if (state is! GuestMode) {
  return const SizedBox.shrink();
}
```

## 📝 Summary

Guest Mode is fully implemented and ready to use! Users can:
- ✅ Access the app without authentication
- ✅ Browse all UI screens
- ✅ See full functionality (UI only)
- ✅ Convert to full user anytime

Perfect for development while APIs are being built! 🎉
