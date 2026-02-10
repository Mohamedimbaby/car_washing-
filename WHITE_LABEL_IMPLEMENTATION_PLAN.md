# White-Label Car Wash Platform - Complete Implementation Plan

## 📋 Project Overview

Building a complete white-label car wash booking platform with:
- **Multi-brand support** via `app_id` (e.g., "shine_wash", "quick_clean")
- **Two user roles**: Customer & Service Provider
- **Firebase backend**: Firestore + Storage + Cloud Messaging
- **Multi-language**: Arabic & English with RTL support

---

## 🗂️ Firebase Structure

```
/apps/{app_id}/
├── config/              # Theme, branding, settings per brand
├── users/               # User profiles with roles
├── service_providers/   # Provider details
├── cars/                # Customer vehicles
├── packages/            # Service packages (provider-owned)
├── slots/               # Available time slots (provider-owned)
└── bookings/            # Booking records
```

---

## ✅ COMPLETED FEATURES

### 1. Core Infrastructure ✅
- [x] Updated `AppConfig` for `/apps/{app_id}/` structure
- [x] Added `UserRoles` constants (customer, service_provider, admin)
- [x] Firebase Storage integration
- [x] Image compression utility

### 2. Car Management Module (مركباتي) ✅
**Domain Layer:**
- [x] `CarEntity` - Car data model
- [x] `CarRepository` - Abstract interface
- [x] Use Cases: Get, Add, Update, Delete

**Data Layer:**
- [x] `CarModel` - Firestore mapping
- [x] `CarRepositoryImpl` - Full implementation with:
  - Firebase Storage upload
  - Image compression (max 1MB)
  - Default car logic
  - Batch operations

**Presentation Layer:**
- [x] `CarCubit` - State management
- [x] `CarState` - Loading, Success, Error states

**Features Implemented:**
- ✅ Upload car image to Storage (`/apps/{app_id}/car_images/`)
- ✅ Mandatory fields: Plate, Brand, Model, Color, Year, Image
- ✅ Arabic text support
- ✅ Set default car
- ✅ Edit/Delete operations
- ✅ Image compression before upload

---

## 🚧 IN PROGRESS

### 3. Car Management UI 🏗️
**Need to Build:**
- [ ] `MyCarsPage` - List view with cards
- [ ] `AddCarPage` - Form with image picker
- [ ] `EditCarPage` - Edit form
- [ ] Car card widget
- [ ] Image picker widget
- [ ] Arabic input support

---

## 📝 PENDING FEATURES

### Customer App Features

#### 4. Profile Management
- [ ] Update `UserEntity` to include:
  - `user_role` (customer/service_provider)
  - `profile_photo`
  - `registration_date`
- [ ] Profile display page
- [ ] Profile edit page
- [ ] Photo upload to Storage (`/apps/{app_id}/user_photos/`)

#### 5. FCM Notifications
- [ ] FCM token storage (`users/{userId}/fcmTokens`)
- [ ] Notification entity & repository
- [ ] Cloud Function: `onBookingStatusChange`
- [ ] In-app notification list
- [ ] Read/unread status
- [ ] Notification payload handling

---

### Service Provider App Features

#### 6. Package Management (إدارة الباقات)
**Domain:**
- [ ] `PackageEntity` with fields:
  - name, nameAr, description
  - price (EGP), duration
  - services included (array)
  - imageUrl, isActive
  - providerId

**Features:**
- [ ] Add package page
- [ ] My packages list
- [ ] Edit/delete package
- [ ] Toggle active status
- [ ] Booking count per package

#### 7. Slot Management (إدارة المواعيد)
**Domain:**
- [ ] `SlotEntity` with:
  - date, time slots array
  - capacity per slot
  - booked count
  - providerId

**Features:**
- [ ] Add slots page (single & bulk)
- [ ] Calendar view
- [ ] Capacity management
- [ ] Prevent double-booking (Firestore transactions)
- [ ] Weekly recurring slots

#### 8. Provider Bookings View
**Features:**
- [ ] Tabs: All | Pending | Confirmed | Completed | Reported
- [ ] Booking cards with:
  - Customer info (name, phone)
  - Car details (image, plate)
  - Package name + price
  - Date & time
  - Status badge
  - Action buttons

#### 9. Provider Dashboard (لوحة التحكم)
**Metrics:**
- [ ] Pending bookings count (real-time)
- [ ] Completed bookings count
- [ ] Total income calculation:
  ```dart
  // Query completed bookings
  .where('providerId', '==', userId)
  .where('status', '==', 'completed')
  // Sum all booking.price
  ```
- [ ] Recent bookings list (last 5)
- [ ] Quick action buttons

#### 10. Booking Actions
**Confirm Booking:**
- [ ] Update status: `pending` → `confirmed`
- [ ] Trigger Cloud Function
- [ ] Send FCM notification to customer
- [ ] Update slot availability

**Mark as Finished:**
- [ ] Update status: `confirmed` → `completed`
- [ ] Add completion timestamp
- [ ] Trigger notification
- [ ] Update income dashboard
- [ ] Request customer rating (optional)

**Report Booking:**
- [ ] Report reasons (checkboxes):
  - Customer no-show (العميل لم يحضر)
  - Extremely dirty vehicle
  - Unpaid extras requested
  - Inappropriate behavior
  - Payment issue
  - Other
- [ ] Additional details text field
- [ ] Store report in booking document
- [ ] Trigger admin notification

#### 11. Customer Management (عملائي)
- [ ] Aggregate unique customers from bookings
- [ ] Display metrics per customer:
  - Total bookings
  - Total revenue
  - Last booking date
  - Contact info
- [ ] Search by name/phone
- [ ] View customer booking history

---

## 🌐 Multi-Language & UI

### 12. Internationalization
- [ ] Add `flutter_localizations` package
- [ ] Create `AppLocalizations` class
- [ ] Arabic translations (ar.json)
- [ ] English translations (en.json)
- [ ] RTL layout support for Arabic
- [ ] Language selector in settings
- [ ] Store user language preference in Firestore

**Key Translations Needed:**
```dart
// Arabic
مركباتي → My Cars
إضافة مركبة → Add Car
رقم اللوحة → License Plate
ماركة السيارة → Car Brand
الموديل → Model
اللون → Color
السنة → Year
// ... and all UI text
```

---

## 🔐 Security & Backend

### 13. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /apps/{appId}/bookings/{bookingId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         resource.data.providerId == request.auth.uid);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        resource.data.providerId == request.auth.uid;
    }
    
    match /apps/{appId}/cars/{carId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /apps/{appId}/packages/{packageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        resource.data.providerId == request.auth.uid;
    }
  }
}
```

### 14. Cloud Functions
**onBookingStatusChange:**
```javascript
exports.onBookingStatusChange = functions.firestore
  .document('/apps/{appId}/bookings/{bookingId}')
  .onUpdate(async (change, context) => {
    const newStatus = change.after.data().status;
    const oldStatus = change.before.data().status;
    
    if (oldStatus !== newStatus) {
      // Send FCM notification
      const customerId = change.after.data().userId;
      await sendNotification(customerId, {
        title: getNotificationTitle(newStatus),
        body: getNotificationBody(newStatus, change.after.data()),
        data: {
          bookingId: context.params.bookingId,
          status: newStatus,
        }
      });
    }
  });
```

**onBookingCreated:**
```javascript
exports.onBookingCreated = functions.firestore
  .document('/apps/{appId}/bookings/{bookingId}')
  .onCreate(async (snap, context) => {
    // Update slot capacity
    const booking = snap.data();
    await updateSlotCapacity(
      context.params.appId,
      booking.slotId,
      -1 // Decrement
    );
  });
```

**aggregateProviderIncome:**
```javascript
exports.aggregateProviderIncome = functions.firestore
  .document('/apps/{appId}/bookings/{bookingId}')
  .onUpdate(async (change, context) => {
    if (change.after.data().status === 'completed' &&
        change.before.data().status !== 'completed') {
      // Update provider's income stats
      const providerId = change.after.data().providerId;
      const price = change.after.data().price;
      
      await updateProviderStats(
        context.params.appId,
        providerId,
        price
      );
    }
  });
```

### 15. Firebase Storage Rules
```javascript
service firebase.storage {
  match /b/{bucket}/o {
    match /apps/{appId}/car_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.resource.size < 1 * 1024 * 1024; // 1MB limit
    }
    
    match /apps/{appId}/user_photos/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.resource.size < 2 * 1024 * 1024; // 2MB limit
    }
  }
}
```

---

## 📦 Dependencies Status

### Installed ✅
- `firebase_core` ✅
- `firebase_auth` ✅
- `firebase_firestore` ✅
- `firebase_storage` ✅ NEW
- `firebase_messaging` ✅
- `image` ✅ NEW (for compression)
- `image_picker` ✅
- `flutter_bloc` ✅
- `get_it` ✅
- `dartz` ✅
- `intl` ✅

### Need to Add
- [ ] `flutter_localizations` - For i18n
- [ ] `easy_localization` or `intl_translation` - Translation management

---

## 📊 Implementation Progress

```
Overall Progress: 35% Complete

Core Infrastructure:        ████████████████████ 100%
Car Management (Backend):   ████████████████████ 100%
Car Management (UI):        ████░░░░░░░░░░░░░░░░  20%
Profile Management:         ░░░░░░░░░░░░░░░░░░░░   0%
FCM Notifications:          ░░░░░░░░░░░░░░░░░░░░   0%
Provider Packages:          ░░░░░░░░░░░░░░░░░░░░   0%
Provider Slots:             ░░░░░░░░░░░░░░░░░░░░   0%
Provider Dashboard:         ░░░░░░░░░░░░░░░░░░░░   0%
Provider Bookings:          ░░░░░░░░░░░░░░░░░░░░   0%
Provider Customers:         ░░░░░░░░░░░░░░░░░░░░   0%
Multi-language:             ░░░░░░░░░░░░░░░░░░░░   0%
Security Rules:             ░░░░░░░░░░░░░░░░░░░░   0%
Cloud Functions:            ░░░░░░░░░░░░░░░░░░░░   0%
```

---

## 🎯 Next Immediate Steps

1. **Complete Car Management UI** (Priority 1)
   - Build `MyCarsPage` with list
   - Create `AddCarPage` with form & image picker
   - Add car card widget
   - Test full CRUD flow

2. **Update User Entity** (Priority 2)
   - Add `user_role` field
   - Add profile photo field
   - Update auth flow to set role

3. **Build Provider Dashboard** (Priority 3)
   - Create metrics widgets
   - Real-time listeners for counts
   - Income calculation
   - Recent bookings list

4. **Package Management** (Priority 4)
   - Entity, Repository, Use Cases
   - Add/Edit/Delete packages
   - Package list UI

---

## 📚 Files Created So Far

### Core
- `lib/core/config/app_config.dart` ✅ (Updated)
- `lib/core/constants/user_roles.dart` ✅ (New)

### Cars Module
- `lib/features/cars/domain/entities/car_entity.dart` ✅
- `lib/features/cars/domain/repositories/car_repository.dart` ✅
- `lib/features/cars/domain/usecases/get_cars_usecase.dart` ✅
- `lib/features/cars/domain/usecases/add_car_usecase.dart` ✅
- `lib/features/cars/domain/usecases/update_car_usecase.dart` ✅
- `lib/features/cars/domain/usecases/delete_car_usecase.dart` ✅
- `lib/features/cars/data/models/car_model.dart` ✅
- `lib/features/cars/data/repositories/car_repository_impl.dart` ✅
- `lib/features/cars/presentation/cubit/car_state.dart` ✅
- `lib/features/cars/presentation/cubit/car_cubit.dart` ✅

---

## 🚀 Estimated Timeline

- **Car Management UI**: 2-3 hours
- **Profile Management**: 2-3 hours
- **Provider Dashboard**: 3-4 hours
- **Package Management**: 3-4 hours
- **Slot Management**: 4-5 hours
- **Booking Actions**: 2-3 hours
- **FCM Notifications**: 3-4 hours
- **Multi-language**: 4-5 hours
- **Security Rules**: 1-2 hours
- **Cloud Functions**: 4-6 hours

**Total Estimated**: 28-39 hours

---

## 💡 Design Patterns Used

- **Clean Architecture** - Domain/Data/Presentation layers
- **Repository Pattern** - Data access abstraction
- **Use Case Pattern** - Single-responsibility business logic
- **Cubit/Bloc** - State management
- **Dependency Injection** - GetIt for IoC
- **Result Pattern** - Either (Dartz) for error handling

---

## 🎨 UI/UX Considerations

1. **Arabic Support**:
   - RTL layout automatically handled by Flutter
   - Arabic fonts (use Material Arabic font)
   - Number localization (٠١٢٣٤٥٦٧٨٩)

2. **Image Uploads**:
   - Show preview before upload
   - Loading indicator during upload
   - Compression feedback
   - Retry on failure

3. **Provider Dashboard**:
   - Real-time updates (StreamBuilder)
   - Pull-to-refresh
   - Empty states with illustrations
   - Quick actions (FAB or action buttons)

4. **Booking Status**:
   - Color-coded badges
   - Status timeline
   - Action buttons based on status
   - Confirmation dialogs for state changes

---

This is a comprehensive, production-ready implementation plan for a complete white-label car wash booking platform! 🚗✨
