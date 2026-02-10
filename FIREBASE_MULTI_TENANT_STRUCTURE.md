# Firebase Multi-Tenant Structure

## Overview

This document describes the Firebase Firestore database structure for the white-label car wash booking platform. The structure supports **multi-tenancy** where each car wash chain (tenant) has isolated data.

## Database Architecture

### Root Structure

```
firestore/
├── tenants/                    # Root collection for all tenants
│   ├── {appId}/               # Document for each white-label app
│   │   ├── servicePackages/   # Subcollection
│   │   ├── addons/            # Subcollection
│   │   ├── bookings/          # Subcollection
│   │   ├── centers/           # Subcollection
│   │   ├── vehicles/          # Subcollection
│   │   └── users/             # Subcollection (optional)
│   └── ...
└── global/                     # Global settings (optional)
```

## Collections & Documents

### 1. `tenants/{appId}`

Main tenant configuration document.

**Fields:**
```javascript
{
  appId: "tenant_001",
  appName: "Premium Car Wash",
  logo: "https://...",
  primaryColor: "#2196F3",
  isActive: true,
  subscription: {
    plan: "premium",  // free, basic, premium
    expiresAt: Timestamp,
  },
  contactEmail: "support@example.com",
  contactPhone: "+1234567890",
  createdAt: Timestamp,
  updatedAt: Timestamp,
}
```

---

### 2. `tenants/{appId}/servicePackages/{packageId}`

Service packages offered by this tenant.

**Fields:**
```javascript
{
  name: "Premium Wash",
  description: "Complete wash and interior cleaning",
  price: 75.00,
  type: "premium",  // basic, standard, premium, detailing
  serviceType: "inCenter",  // inCenter, onLocation, both
  durationMinutes: 60,
  features: [
    "Everything in Standard",
    "Interior wipe down",
    "Dashboard polish",
    "Air freshener",
    "Tire shine"
  ],
  imageUrl: "https://...",
  isActive: true,
  createdAt: Timestamp,
}
```

**Indexes:**
- `serviceType` + `isActive` + `price` (ascending)
- `type` + `isActive`

---

### 3. `tenants/{appId}/addons/{addonId}`

Add-on services available.

**Fields:**
```javascript
{
  name: "Wax Protection",
  description: "Premium wax coating",
  price: 15.00,
  imageUrl: "https://...",
  isActive: true,
  estimatedMinutes: 15,
  createdAt: Timestamp,
}
```

**Indexes:**
- `isActive` + `price` (ascending)

---

### 4. `tenants/{appId}/bookings/{bookingId}`

Customer bookings.

**Fields:**
```javascript
{
  appId: "tenant_001",
  userId: "user_abc123",
  vehicleId: "vehicle_xyz789",
  centerId: "center_001",
  branchId: "branch_001",
  serviceType: "inCenter",  // inCenter, onLocation
  packageId: "package_premium",
  addonIds: ["addon_wax", "addon_engine"],
  scheduledDate: Timestamp,
  timeSlot: "10:00",
  status: "pending",  // pending, confirmed, inProgress, completed, cancelled
  totalPrice: 105.00,
  specialInstructions: "Please focus on the wheels",
  location: "123 Main St",  // For onLocation services
  
  // Tracking
  confirmedAt: Timestamp,
  startedAt: Timestamp,
  completedAt: Timestamp,
  cancelledAt: Timestamp,
  
  // Rating (after completion)
  rating: 5,
  review: "Excellent service!",
  reviewedAt: Timestamp,
  
  // Photos
  beforePhotos: ["https://..."],
  afterPhotos: ["https://..."],
  
  createdAt: Timestamp,
  updatedAt: Timestamp,
}
```

**Indexes:**
- `userId` + `createdAt` (descending)
- `userId` + `status` + `scheduledDate` (ascending)
- `centerId` + `scheduledDate` (ascending)
- `status` + `scheduledDate` (ascending)

---

### 5. `tenants/{appId}/centers/{centerId}`

Car wash center/branch locations.

**Fields:**
```javascript
{
  name: "Downtown Branch",
  address: "123 Main Street, City, State 12345",
  coordinates: {
    latitude: 40.7128,
    longitude: -74.0060,
  },
  phone: "+1234567890",
  email: "downtown@example.com",
  operatingHours: {
    monday: { open: "08:00", close: "18:00" },
    tuesday: { open: "08:00", close: "18:00" },
    // ... other days
  },
  serviceTypes: ["inCenter"],  // inCenter, onLocation, both
  serviceRadius: 10,  // km, for onLocation services
  availableBays: 5,
  photos: ["https://...", "https://..."],
  rating: 4.5,
  totalReviews: 150,
  isActive: true,
  createdAt: Timestamp,
}
```

**Indexes:**
- `coordinates` (geohash for geo queries)
- `isActive` + `rating` (descending)

---

### 6. `tenants/{appId}/vehicles/{vehicleId}`

User's registered vehicles.

**Fields:**
```javascript
{
  userId: "user_abc123",
  make: "Toyota",
  model: "Camry",
  year: 2022,
  color: "Blue",
  licensePlate: "ABC1234",
  vin: "1HGBH41JXMN109186",  // Optional
  isDefault: true,
  createdAt: Timestamp,
}
```

**Indexes:**
- `userId` + `createdAt` (descending)

---

### 7. `tenants/{appId}/timeSlots/{slotId}` (Optional - for dynamic scheduling)

Available time slots per center/date.

**Fields:**
```javascript
{
  centerId: "center_001",
  date: Timestamp,  // Date only (time set to midnight)
  startTime: "10:00",
  endTime: "11:00",
  availableSlots: 3,
  totalSlots: 5,
  isAvailable: true,
}
```

**Indexes:**
- `centerId` + `date` + `startTime`

---

## Multi-Tenant Access Pattern

### Setting App ID

```dart
// Set at app initialization
import 'package:washing_cars/core/config/app_config.dart';

void main() async {
  // Option 1: Build-time constant
  AppConfig.setAppId('tenant_premium_001');
  
  // Option 2: From Firebase Remote Config
  // final appId = await remoteConfig.getString('app_id');
  // AppConfig.setAppId(appId);
  
  runApp(MyApp());
}
```

### Querying Data

All queries automatically include the `appId` filter:

```dart
// Example: Fetch service packages
firestore
  .collection('tenants')
  .doc(AppConfig.appId)  // Current app's tenant ID
  .collection('servicePackages')
  .where('isActive', isEqualTo: true)
  .get();
```

### Creating Bookings

```dart
// Bookings are stored under the tenant's collection
firestore
  .collection('tenants')
  .doc(AppConfig.appId)
  .collection('bookings')
  .add({
    'appId': AppConfig.appId,  // Also stored in document for reference
    'userId': currentUserId,
    // ... other fields
  });
```

---

## Security Rules

Example Firestore security rules for multi-tenancy:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Tenants root
    match /tenants/{appId} {
      // Allow read access to tenant config
      allow read: if true;
      
      // Service packages - public read
      match /servicePackages/{packageId} {
        allow read: if true;
        allow write: if false;  // Only via admin
      }
      
      // Addons - public read
      match /addons/{addonId} {
        allow read: if true;
        allow write: if false;
      }
      
      // Bookings - user can only access their own
      match /bookings/{bookingId} {
        allow read: if isOwner(resource.data.userId);
        allow create: if isAuthenticated() && 
                         request.resource.data.userId == request.auth.uid &&
                         request.resource.data.appId == appId;
        allow update: if isOwner(resource.data.userId);
      }
      
      // Vehicles - user can only access their own
      match /vehicles/{vehicleId} {
        allow read, write: if isOwner(resource.data.userId);
      }
      
      // Centers - public read
      match /centers/{centerId} {
        allow read: if true;
        allow write: if false;
      }
    }
  }
}
```

---

## Sample Data Setup

### Initialize Default Tenant

```javascript
// Add to Firestore manually or via script
db.collection('tenants').doc('default_tenant').set({
  appId: 'default_tenant',
  appName: 'Car Wash Pro',
  isActive: true,
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
});

// Add sample packages
const packages = [
  {
    name: 'Basic Wash',
    price: 25,
    type: 'basic',
    serviceType: 'inCenter',
    // ...
  },
  // ... more packages
];

packages.forEach(pkg => {
  db.collection('tenants/default_tenant/servicePackages').add(pkg);
});
```

---

## Performance Considerations

1. **Composite Indexes**: Create composite indexes for common query patterns
2. **Pagination**: Use `limit()` and cursor-based pagination for large result sets
3. **Caching**: Cache frequently accessed data (packages, addons) locally
4. **Geoqueries**: Use `geoflutterfire` package for location-based center searches
5. **Denormalization**: Store commonly accessed data together to reduce reads

---

## Migration from Mock Data

The repository implementation automatically falls back to mock data if Firebase collections are empty. To migrate to full Firebase:

1. **Set up tenant document** in Firestore
2. **Add service packages** for your tenant
3. **Add addons** for your tenant
4. **Add center locations**
5. Remove mock data fallback once collections are populated

---

## Testing

For development/testing, you can use the default tenant:

```dart
AppConfig.setAppId('default_tenant');
```

For production, each white-label deployment gets its own `appId`.

---

## Next Steps

1. Set up Firebase project and enable Firestore
2. Create tenant document
3. Add sample data (packages, addons, centers)
4. Configure security rules
5. Test booking flow end-to-end
