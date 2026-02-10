## 🔥 Firebase Setup Guide

The project has been converted to use Firebase instead of REST APIs! This provides:
- ✅ Authentication (email/password)
- ✅ Cloud Firestore (real-time database)
- ✅ Cloud Messaging (push notifications)
- ✅ No custom backend needed!

## 🚀 Quick Setup (3 Steps)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `car-wash-app`
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Add iOS App

1. In Firebase Console, click iOS icon
2. **iOS bundle ID**: `com.carwash.washingCars`
   - Find in `ios/Runner.xcodeproj/project.pbxproj`
3. Download `GoogleService-Info.plist`
4. **Important**: Place file in `ios/Runner/` folder
5. Click "Next" → "Next" → "Continue to console"

### Step 3: Add Android App

1. In Firebase Console, click Android icon
2. **Android package name**: `com.carwash.washing_cars`
   - Find in `android/app/build.gradle`
3. Download `google-services.json`
4. **Important**: Place file in `android/app/` folder
5. Click "Next" → "Next" → "Continue to console"

## 📝 Enable Firebase Services

### 1. Authentication

```
Firebase Console → Authentication → Get Started
→ Sign-in method → Email/Password → Enable → Save
```

### 2. Cloud Firestore

```
Firebase Console → Firestore Database → Create database
→ Start in test mode (for development)
→ Select location (us-central recommended)
→ Enable
```

**Test Mode Rules (Development Only):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 3, 1);
    }
  }
}
```

### 3. Production Rules (When Ready)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Users can manage their vehicles
    match /vehicles/{vehicleId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Anyone can read centers, only providers can write
    match /centers/{centerId} {
      allow read: if true;
      allow write: if request.auth != null; // Add role check
    }
    
    // Users can read their bookings
    match /bookings/{bookingId} {
      allow read: if request.auth != null && 
                     (request.auth.uid == resource.data.userId || 
                      request.auth.uid == resource.data.providerId);
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
    
    // Anyone can read reviews
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📁 File Placement

Make sure these files are in the correct locations:

```
washing_car/
├── android/
│   └── app/
│       └── google-services.json  ✅ Place here
│
└── ios/
    └── Runner/
        └── GoogleService-Info.plist  ✅ Place here
```

## 🔧 Install Dependencies

```bash
cd /Users/imbaby/Desktop/Washing-Cars/washing_car

# Get dependencies
flutter pub get

# For iOS (Mac only)
cd ios
pod install
cd ..
```

## 🗄️ Firestore Database Structure

### Collections Created Automatically

```
firestore/
├── users/              # User profiles
│   └── {userId}/
│       ├── email
│       ├── fullName
│       ├── phoneNumber
│       ├── createdAt
│       └── isEmailVerified
│
├── vehicles/           # User vehicles
│   └── {vehicleId}/
│       ├── userId
│       ├── make
│       ├── model
│       ├── color
│       ├── licensePlate
│       ├── year
│       └── isDefault
│
├── centers/            # Car wash centers
│   └── {centerId}/
│       ├── name
│       ├── description
│       ├── address
│       ├── latitude
│       ├── longitude
│       ├── rating
│       └── services
│
├── bookings/           # Service bookings
│   └── {bookingId}/
│       ├── userId
│       ├── vehicleId
│       ├── centerId
│       ├── serviceType
│       ├── scheduledDate
│       ├── status
│       └── totalPrice
│
├── reviews/            # User reviews
│   └── {reviewId}/
│       ├── userId
│       ├── centerId
│       ├── bookingId
│       ├── rating
│       └── comment
│
└── staff/              # Provider staff
    └── {staffId}/
        ├── centerId
        ├── fullName
        ├── email
        └── role
```

## ✅ Test Authentication

### 1. Run the App

```bash
flutter run
```

### 2. Test Registration

1. Tap "Sign Up"
2. Enter:
   - Name: Test User
   - Email: test@example.com
   - Password: test123
3. Tap "Sign Up"
4. ✅ Should create account and login

### 3. Verify in Firebase Console

```
Firebase Console → Authentication → Users
```
You should see your test user!

### 4. Check Firestore

```
Firebase Console → Firestore Database
```
You should see a `users` collection with your data!

## 🔥 Firebase Features Used

### 1. Firebase Authentication
```dart
// Login
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Register
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Logout
await FirebaseAuth.instance.signOut();
```

### 2. Cloud Firestore
```dart
// Add data
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .set(userData);

// Get data
final doc = await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get();

// Real-time updates
FirebaseFirestore.instance
  .collection('bookings')
  .where('userId', isEqualTo: currentUser.uid)
  .snapshots()
  .listen((snapshot) {
    // Update UI automatically!
  });
```

### 3. Firebase Cloud Messaging
```dart
// Already configured in pubspec.yaml
// firebase_messaging: ^15.1.0

// Get FCM token
final token = await FirebaseMessaging.instance.getToken();

// Listen to messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Notification received: ${message.notification?.title}');
});
```

## 🌐 Web Support (Bonus!)

To enable web support:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure for all platforms
flutterfire configure
```

## 🐛 Troubleshooting

### iOS Build Issues

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Android Build Issues

```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

### "Firebase not initialized"

Make sure you have:
1. ✅ `google-services.json` in `android/app/`
2. ✅ `GoogleService-Info.plist` in `ios/Runner/`
3. ✅ Run `flutter pub get`
4. ✅ Restart IDE

### Authentication Errors

Check Firebase Console:
```
Authentication → Sign-in method → Email/Password → Enabled
```

### Firestore Permission Denied

Check Firestore Rules:
```
Firestore Database → Rules → Use test mode for development
```

## 📊 Advantages of Firebase

### ✅ Benefits

1. **No Backend Needed** - Firebase handles everything
2. **Real-time Updates** - Data syncs automatically
3. **Offline Support** - Works without internet
4. **Authentication** - Built-in user management
5. **Scalable** - Handles millions of users
6. **Security** - Built-in security rules
7. **Free Tier** - Generous free quota

### 📈 Firebase Pricing (Free Tier)

- **Authentication**: 10K verifications/month
- **Firestore**: 50K reads, 20K writes, 20K deletes/day
- **Storage**: 5GB
- **Hosting**: 10GB transfer/month

Perfect for development and small-scale apps!

## 🎯 What's Converted

### ✅ Completed

- ✅ Authentication (login/register)
- ✅ User profile storage
- ✅ Firebase initialization
- ✅ Dependency injection updated
- ✅ Data source layer converted
- ✅ Guest mode still works

### 🔄 Next Steps (When You Need Them)

Create services for:
- [ ] Vehicle CRUD operations
- [ ] Booking management
- [ ] Center search
- [ ] Review system
- [ ] Staff management

All follow the same pattern as authentication!

## 📚 Example: Add Vehicle to Firebase

```dart
// In vehicle_remote_data_source.dart
Future<void> addVehicle(VehicleModel vehicle) async {
  await FirebaseFirestore.instance
    .collection('vehicles')
    .doc(vehicle.id)
    .set({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'make': vehicle.make,
      'model': vehicle.model,
      'color': vehicle.color,
      'licensePlate': vehicle.licensePlate,
      'year': vehicle.year,
      'createdAt': FieldValue.serverTimestamp(),
    });
}

// Get user's vehicles
Future<List<VehicleModel>> getVehicles() async {
  final snapshot = await FirebaseFirestore.instance
    .collection('vehicles')
    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    .get();
    
  return snapshot.docs
    .map((doc) => VehicleModel.fromJson(doc.data()))
    .toList();
}
```

## 🎊 Summary

Firebase setup is:
1. ✅ Create project
2. ✅ Add config files
3. ✅ Enable services
4. ✅ Run app!

No custom backend needed! 🚀

---

**Need Help?** Check [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
