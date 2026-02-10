# 🔥 Firebase Quick Reference

## 🚀 Fastest Way to Get Started

### 1. Setup Firebase (15 minutes)

```bash
# 1. Go to: https://console.firebase.google.com/
# 2. Create project: "car-wash-app"
# 3. Add iOS app → Download GoogleService-Info.plist
# 4. Add Android app → Download google-services.json
# 5. Enable Authentication (Email/Password)
# 6. Enable Firestore (Test mode)
```

### 2. Add Config Files

```
washing_car/
├── android/app/
│   └── google-services.json      ← Place here
└── ios/Runner/
    └── GoogleService-Info.plist  ← Place here
```

### 3. Run App

```bash
cd /Users/imbaby/Desktop/Washing-Cars/washing_car
flutter pub get
flutter run
```

### 4. Test

- Tap "Sign Up"
- Create account → Check Firebase Console
- See user in Authentication ✅
- See data in Firestore ✅

## 📖 Common Operations

### Authentication

```dart
// Register
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Login
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Logout
await FirebaseAuth.instance.signOut();

// Current user
final user = FirebaseAuth.instance.currentUser;
```

### Firestore CRUD

```dart
// Create/Update
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .set({'name': 'John'});

// Read
final doc = await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get();

// Query
final users = await FirebaseFirestore.instance
  .collection('users')
  .where('age', isGreaterThan: 18)
  .get();

// Delete
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .delete();

// Real-time
FirebaseFirestore.instance
  .collection('bookings')
  .snapshots()
  .listen((snapshot) {
    // Auto-updates!
  });
```

## 🗄️ Database Structure

```
firestore/
├── users/{userId}
│   ├── email
│   ├── fullName
│   ├── phoneNumber
│   └── createdAt
│
├── vehicles/{vehicleId}
│   ├── userId
│   ├── make
│   ├── model
│   └── licensePlate
│
├── bookings/{bookingId}
│   ├── userId
│   ├── vehicleId
│   ├── centerId
│   ├── status
│   └── scheduledDate
│
└── centers/{centerId}
    ├── name
    ├── address
    ├── latitude
    └── longitude
```

## 🎯 Key Files Modified

```
✅ main.dart - Firebase initialization
✅ auth_remote_data_source.dart - Firebase Auth
✅ injection.dart - Firebase DI
✅ firebase_service.dart - Helper methods

📚 FIREBASE_SETUP.md - Complete guide
📚 FIREBASE_CONVERSION_SUMMARY.md - What changed
📚 FIREBASE_QUICK_REFERENCE.md - This file
```

## 🔐 Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Vehicles
    match /vehicles/{vehicleId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Bookings
    match /bookings/{bookingId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## 🐛 Troubleshooting

### Error: Firebase not initialized
```bash
# Make sure config files are in place:
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist

# Then:
flutter clean
flutter pub get
flutter run
```

### Error: Authentication failed
```
Check: Firebase Console → Authentication → Sign-in method
Enable: Email/Password
```

### Error: Permission denied
```
Check: Firestore Database → Rules
Use test mode for development:
allow read, write: if request.time < timestamp.date(2025, 3, 1);
```

## 📊 Firebase Console Links

- **Project**: https://console.firebase.google.com/
- **Authentication**: → Authentication → Users
- **Database**: → Firestore Database
- **Rules**: → Firestore Database → Rules
- **Usage**: → Usage and billing

## 💰 Pricing (Free Tier)

- **Authentication**: 10,000/month
- **Firestore Reads**: 50,000/day
- **Firestore Writes**: 20,000/day
- **Storage**: 5 GB
- **Perfect for development!** ✅

## 🎓 Learning Resources

- [Firebase Docs](https://firebase.google.com/docs)
- [Flutter Firebase](https://firebase.google.com/docs/flutter/setup)
- [Firestore Guide](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Auth](https://firebase.google.com/docs/auth)

## ✅ Checklist

Before running:
- [ ] Firebase project created
- [ ] google-services.json added
- [ ] GoogleService-Info.plist added
- [ ] Authentication enabled
- [ ] Firestore enabled
- [ ] `flutter pub get` run

After running:
- [ ] Can register user
- [ ] Can login
- [ ] User appears in Firebase Console
- [ ] Data appears in Firestore

## 🎊 You're All Set!

Firebase is integrated and ready. Just:
1. Setup Firebase project
2. Add config files
3. Run app
4. Test authentication

That's it! 🚀
