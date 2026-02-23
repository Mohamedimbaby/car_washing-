# 🔥 Firebase Schema — Single Source of Truth

> **Version:** 1.0 · **Last updated:** 2026-02-23
> **Audience:** Client App Developer + Provider App Developer
> **Database:** Cloud Firestore (NoSQL, document-oriented)

This is the **only** schema file both apps must follow.
If something is not in this document, it does not exist in Firebase.

---

## Table of Contents

1. [Core Rules](#1-core-rules)
2. [Root Path Convention](#2-root-path-convention)
3. [Shared Enums](#3-shared-enums)
4. [Collections & Documents](#4-collections--documents)
   - 4.1 [users](#41-users)
   - 4.2 [cars (vehicles)](#42-cars-vehicles)
   - 4.3 [service_providers](#43-service_providers)
   - 4.4 [packages](#44-packages)
   - 4.5 [addons](#45-addons)
   - 4.6 [schedule_configs](#46-schedule_configs)
   - 4.7 [slots](#47-slots)
   - 4.8 [bookings](#48-bookings)
   - 4.9 [reviews](#49-reviews)
5. [Write Ownership Matrix](#5-write-ownership-matrix)
6. [Booking Lifecycle](#6-booking-lifecycle)
7. [Required Indexes](#7-required-indexes)
8. [Security Rules Summary](#8-security-rules-summary)
9. [Field Naming Rules](#9-field-naming-rules)
10. [Migration Notes](#10-migration-notes)

---

## 1. Core Rules

| # | Rule |
|---|------|
| 1 | **Single root path:** `apps/{appId}/...` — no `tenants/`, no root-level collections. |
| 2 | **Read-optimized:** each document must contain enough data for its screen. No runtime joins. |
| 3 | **Money as doubles** for now (`price: 75.0`). Both apps must treat price the same way (EGP default). |
| 4 | **Server timestamps:** every mutable document must have `createdAt` and `updatedAt`. |
| 5 | **`appId`** is stored inside every document **and** in the path — enables cross-tenant queries if needed later. |
| 6 | **Bilingual fields:** any user-facing text field must have an Arabic companion (`name` → `nameAr`). |
| 7 | **No client writes to payment/refund final status.** Backend only. |

---

## 2. Root Path Convention

```
apps/{appId}/
├── users/{uid}
│   └── fcmTokens/{tokenId}
├── cars/{carId}
├── service_providers/{providerId}
├── packages/{packageId}
├── addons/{addonId}
├── schedule_configs/{configId}
├── slots/{slotDocId}
├── bookings/{bookingId}
└── reviews/{reviewId}
```

**`{appId}`** = the white-label tenant key, set once at app launch via `AppConfig.appId`.

---

## 3. Shared Enums

Both apps **must** serialize these values as the exact strings below.

### UserRole
| Value | Description |
|-------|-------------|
| `customer` | Client app user |
| `provider` | Provider app user (owner/manager) |
| `staff` | Provider employee |
| `admin` | Platform admin |

### BookingStatus
| Value | Description |
|-------|-------------|
| `pending` | Customer created, awaiting provider confirmation |
| `confirmed` | Provider accepted |
| `inProgress` | Service started |
| `completed` | Service finished |
| `cancelled` | Cancelled by either party |
| `noShow` | Customer did not arrive |

### ServiceType
| Value | Description |
|-------|-------------|
| `inCenter` | Customer comes to the wash center |
| `onLocation` | Provider goes to the customer location |

### PaymentStatus
| Value | Description |
|-------|-------------|
| `pending` | Not yet paid |
| `processing` | Payment in progress |
| `succeeded` | Payment completed |
| `failed` | Payment failed |
| `refunded` | Full refund |

---

## 4. Collections & Documents

### 4.1 `users`

**Path:** `apps/{appId}/users/{uid}`

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `userId` | `string` | ✅ | Auth | Same as document ID (`{uid}`) |
| `appId` | `string` | ✅ | Client | Runtime tenant key |
| `role` | `string` | ✅ | Auth/Admin | Enum: `UserRole` |
| `name` | `string` | ✅ | Client | Display name |
| `email` | `string` | ✅ | Auth | Firebase Auth email |
| `phone` | `string` | ❌ | Client | E.164 format |
| `profilePhoto` | `string` | ❌ | Client | URL |
| `address` | `string` | ❌ | Client | Free text address |
| `isEmailVerified` | `bool` | ❌ | Auth | Defaults `false` |
| `isPhoneVerified` | `bool` | ❌ | Auth | Defaults `false` |
| `registrationDate` | `timestamp` | ✅ | Client | When the profile was created |
| `createdAt` | `timestamp` | ✅ | Client | Server timestamp |
| `updatedAt` | `timestamp` | ✅ | Client | Server timestamp |

**Subcollection:** `apps/{appId}/users/{uid}/fcmTokens/{tokenId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `token` | `string` | ✅ | FCM device token |
| `platform` | `string` | ✅ | `ios` / `android` |
| `createdAt` | `timestamp` | ✅ | |

---

### 4.2 `cars` (vehicles)

**Path:** `apps/{appId}/cars/{carId}`

> ⚠️ **Important:** Both apps must call this collection `cars`, not `vehicles`.

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `userId` | `string` | ✅ | Client | Owner's UID |
| `appId` | `string` | ✅ | Client | Tenant key |
| `plateNumber` | `string` | ✅ | Client | License plate |
| `brand` | `string` | ✅ | Client | e.g. `Toyota` |
| `model` | `string` | ✅ | Client | e.g. `Camry` |
| `color` | `string` | ✅ | Client | e.g. `Blue` |
| `year` | `int` | ✅ | Client | e.g. `2022` |
| `imageUrl` | `string` | ❌ | Client | Photo of car |
| `isDefault` | `bool` | ❌ | Client | Defaults `false` |
| `createdAt` | `timestamp` | ✅ | Client | Server timestamp |
| `updatedAt` | `timestamp` | ✅ | Client | Server timestamp |

---

### 4.3 `service_providers`

**Path:** `apps/{appId}/service_providers/{providerId}`

> The `{providerId}` is the same as the Firebase Auth UID of the provider user.

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `providerId` | `string` | ✅ | Provider | Same as doc ID |
| `appId` | `string` | ✅ | Provider | Tenant key |
| `businessName` | `string` | ✅ | Provider | e.g. `Shine Wash` |
| `businessNameAr` | `string` | ❌ | Provider | Arabic name |
| `ownerName` | `string` | ✅ | Provider | Owner full name |
| `phone` | `string` | ✅ | Provider | Business phone |
| `email` | `string` | ✅ | Provider | Business email |
| `logoUrl` | `string` | ❌ | Provider | Logo image |
| `address` | `string` | ❌ | Provider | Free text |
| `city` | `string` | ❌ | Provider | |
| `country` | `string` | ❌ | Provider | ISO-3166 code |
| `geo` | `map` | ❌ | Provider | `{ lat: double, lng: double }` |
| `serviceTypes` | `array<string>` | ✅ | Provider | `["inCenter"]`, `["onLocation"]`, or both |
| `isActive` | `bool` | ✅ | Provider | Defaults `true` |
| `rating` | `double` | ❌ | Backend | Aggregate rating |
| `totalReviews` | `int` | ❌ | Backend | Aggregate count |
| `createdAt` | `timestamp` | ✅ | Provider | Server timestamp |
| `updatedAt` | `timestamp` | ✅ | Provider | Server timestamp |

---

### 4.4 `packages`

**Path:** `apps/{appId}/packages/{packageId}`

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `providerId` | `string` | ✅ | Provider | Owner provider UID |
| `appId` | `string` | ✅ | Provider | Tenant key |
| `name` | `string` | ✅ | Provider | English name |
| `nameAr` | `string` | ❌ | Provider | Arabic name |
| `description` | `string` | ✅ | Provider | English desc |
| `descriptionAr` | `string` | ❌ | Provider | Arabic desc |
| `price` | `double` | ✅ | Provider | e.g. `75.0` |
| `currency` | `string` | ❌ | Provider | Default `EGP` |
| `duration` | `int` | ✅ | Provider | Duration in **minutes** |
| `services` | `array<string>` | ✅ | Provider | Feature list `["foam","vacuum"]` |
| `imageUrl` | `string` | ❌ | Provider | Package image |
| `isActive` | `bool` | ❌ | Provider | Defaults `true` |
| `createdAt` | `timestamp` | ✅ | Provider | Server timestamp |
| `updatedAt` | `timestamp` | ✅ | Provider | Server timestamp |

> **⚠️ Firestore field name is `duration`, NOT `durationMinutes`.** Both apps must use `duration`.

---

### 4.5 `addons`

**Path:** `apps/{appId}/addons/{addonId}`

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `addonId` | `string` | ❌ | — | Same as doc ID |
| `providerId` | `string` | ✅ | Provider | Owner provider UID |
| `appId` | `string` | ✅ | Provider | Tenant key |
| `name` | `string` | ✅ | Provider | English name |
| `nameAr` | `string` | ❌ | Provider | Arabic name |
| `description` | `string` | ✅ | Provider | |
| `descriptionAr` | `string` | ❌ | Provider | Arabic desc |
| `price` | `double` | ✅ | Provider | |
| `currency` | `string` | ❌ | Provider | Default `EGP` |
| `durationMinutes` | `int` | ❌ | Provider | Extra time added |
| `iconUrl` | `string` | ❌ | Provider | Icon/image |
| `isActive` | `bool` | ❌ | Provider | Defaults `true` |
| `createdAt` | `timestamp` | ✅ | Provider | Server timestamp |
| `updatedAt` | `timestamp` | ✅ | Provider | Server timestamp |

---

### 4.6 `schedule_configs`

**Path:** `apps/{appId}/schedule_configs/{configId}`

> Provider creates one config per "schedule generation session". The provider app uses this to auto-generate slot documents.

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `providerId` | `string` | ✅ | Provider | Owner UID |
| `appId` | `string` | ✅ | Provider | Tenant key |
| `washingCapacity` | `int` | ✅ | Provider | Max concurrent washes per slot |
| `workingStartTime` | `string` | ✅ | Provider | `"HH:mm"` format, e.g. `"08:00"` |
| `workingEndTime` | `string` | ✅ | Provider | `"HH:mm"` format, e.g. `"22:00"` |
| `offDays` | `array<int>` | ✅ | Provider | Day-of-week numbers `[5, 6]` = Fri, Sat |
| `dateRangeStart` | `timestamp` | ✅ | Provider | First date of slot generation |
| `dateRangeEnd` | `timestamp` | ✅ | Provider | Last date of slot generation |
| `slotDurationMinutes` | `int` | ❌ | Provider | Defaults `30` |
| `createdAt` | `timestamp` | ✅ | Provider | Server timestamp |
| `lastGenerated` | `timestamp` | ❌ | Provider | When slots were last generated |
| `updatedAt` | `timestamp` | ❌ | Provider | Server timestamp |

---

### 4.7 `slots`

**Path:** `apps/{appId}/slots/{slotDocId}`

> Each document = one **day** of availability for a provider.
> The `slots` array contains the individual time windows.

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `providerId` | `string` | ✅ | Provider | Owner UID |
| `appId` | `string` | ✅ | Provider | Tenant key |
| `date` | `timestamp` | ✅ | Provider | Date only (time = midnight) |
| `slots` | `array<map>` | ✅ | Provider | Array of time-slot objects (see below) |
| `createdAt` | `timestamp` | ✅ | Provider | Server timestamp |

**Each item in `slots` array:**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `time` | `string` | ✅ | `"HH:mm"` format |
| `capacity` | `int` | ✅ | Total capacity for this slot |
| `booked` | `int` | ✅ | Currently booked count |

**Computed (client-side):** `available = capacity - booked`

> **Client app:** reads slots where `providerId` matches and `date` matches the selected day.
> **Provider app:** creates/updates slot documents when generating schedule.
> **On booking confirmation:** increment `booked` for the relevant time slot (use `FieldValue.increment(1)`).

---

### 4.8 `bookings`

**Path:** `apps/{appId}/bookings/{bookingId}`

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `bookingId` | `string` | ❌ | — | Same as doc ID |
| `appId` | `string` | ✅ | Client | Tenant key |
| `userId` | `string` | ✅ | Client | Customer UID |
| `providerId` | `string` | ✅ | Client | Provider UID — **CRITICAL: both apps need this!** |
| `vehicleId` | `string` | ✅ | Client | Car document ID |
| `centerId` | `string` | ✅ | Client | Provider/center ID (same as `providerId` for now) |
| `branchId` | `string` | ❌ | Client | If provider has multiple branches |
| `serviceType` | `string` | ✅ | Client | Enum: `ServiceType` |
| `packageId` | `string` | ✅ | Client | Selected package |
| `addonIds` | `array<string>` | ✅ | Client | Selected addons (can be empty `[]`) |
| `scheduledDate` | `timestamp` | ✅ | Client | Scheduled date+time |
| `timeSlot` | `string` | ❌ | Client | `"HH:mm"` slot reference |
| `status` | `string` | ✅ | Both | Enum: `BookingStatus` |
| `totalPrice` | `double` | ✅ | Client | Total amount |
| `currency` | `string` | ❌ | Client | Default `EGP` |
| `specialInstructions` | `string` | ❌ | Client | Customer notes |
| `location` | `string` | ❌ | Client | For `onLocation` service type |
| `paymentStatus` | `string` | ❌ | Backend | Enum: `PaymentStatus` |
| `confirmedAt` | `timestamp` | ❌ | Provider | When provider confirmed |
| `startedAt` | `timestamp` | ❌ | Provider | When service started |
| `completedAt` | `timestamp` | ❌ | Provider | When service finished |
| `cancelledAt` | `timestamp` | ❌ | Both | When booking was cancelled |
| `cancelReason` | `string` | ❌ | Both | Why it was cancelled |
| `createdAt` | `timestamp` | ✅ | Client | Server timestamp |
| `updatedAt` | `timestamp` | ✅ | Both | Server timestamp |

> **⚠️ `providerId` MUST be written by the client app at booking creation.**
> The provider app queries bookings by `providerId == myUid` to see incoming orders.

---

### 4.9 `reviews`

**Path:** `apps/{appId}/reviews/{reviewId}`

| Field | Type | Required | Written By | Notes |
|-------|------|----------|------------|-------|
| `reviewId` | `string` | ❌ | — | Same as doc ID |
| `bookingId` | `string` | ✅ | Client | Must reference a completed booking |
| `userId` | `string` | ✅ | Client | Reviewer UID |
| `providerId` | `string` | ✅ | Client | Which provider |
| `rating` | `int` | ✅ | Client | 1–5 |
| `comment` | `string` | ❌ | Client | Free text |
| `photoUrls` | `array<string>` | ❌ | Client | Review photos |
| `isVisible` | `bool` | ❌ | Admin | Defaults `true` |
| `providerReply` | `string` | ❌ | Provider | Provider's response |
| `repliedAt` | `timestamp` | ❌ | Provider | |
| `createdAt` | `timestamp` | ✅ | Client | Server timestamp |
| `updatedAt` | `timestamp` | ✅ | Both | Server timestamp |

---

## 5. Write Ownership Matrix

| Collection | Client App | Provider App | Backend |
|------------|-----------|-------------|---------|
| `users` | Read/Write own | Read only | — |
| `cars` | CRUD own | Read customer cars for booking | — |
| `service_providers` | Read only | CRUD own | Update rating aggregates |
| `packages` | Read only | CRUD own | — |
| `addons` | Read only | CRUD own | — |
| `schedule_configs` | ❌ | CRUD own | — |
| `slots` | Read only | CRUD own | Increment `booked` atomically |
| `bookings` | Create + Cancel own | Read/Update status for own | Payment status only |
| `reviews` | Create (for completed bookings) | Reply only | Moderation |

---

## 6. Booking Lifecycle

```
Customer creates booking
         │
         ▼
    ┌─────────┐     cancel
    │ pending  │────────────────► cancelled
    └────┬────┘
         │ provider confirms
         ▼
    ┌───────────┐    cancel
    │ confirmed │───────────────► cancelled
    └────┬──────┘
         │ provider starts service
         ▼
    ┌──────────────┐
    │ inProgress   │
    └────┬─────────┘
         │ provider completes
         ▼
    ┌───────────┐
    │ completed │
    └───────────┘
```

**Allowed transitions:**

| From | To | Who |
|------|----|-----|
| `pending` | `confirmed` | Provider |
| `pending` | `cancelled` | Customer or Provider |
| `confirmed` | `inProgress` | Provider |
| `confirmed` | `cancelled` | Customer or Provider |
| `inProgress` | `completed` | Provider |
| `pending` | `noShow` | Provider |
| `confirmed` | `noShow` | Provider |

**On every status change, update:**
- `status` field
- Lifecycle timestamp (`confirmedAt`, `startedAt`, `completedAt`, or `cancelledAt`)
- `updatedAt`

---

## 7. Required Indexes

Create these composite indexes in the Firebase Console or via `firestore.indexes.json`:

| Collection | Fields | Purpose |
|------------|--------|---------|
| `bookings` | `userId` ASC, `createdAt` DESC | Customer: my bookings |
| `bookings` | `providerId` ASC, `createdAt` DESC | Provider: incoming orders |
| `bookings` | `providerId` ASC, `status` ASC, `scheduledDate` ASC | Provider: filter by status |
| `packages` | `providerId` ASC, `isActive` ASC | Provider's active packages |
| `slots` | `providerId` ASC, `date` ASC | Available slots for a provider |
| `reviews` | `providerId` ASC, `createdAt` DESC | Provider reviews |
| `cars` | `userId` ASC, `createdAt` DESC | Customer's cars |

---

## 8. Security Rules Summary

```
Default: DENY ALL

apps/{appId}/users/{uid}:
  read:   any authenticated user
  write:  only the user themselves (uid match)

apps/{appId}/cars/{carId}:
  read:   any authenticated user
  create: any authenticated user
  update/delete: only owner (resource.data.userId == auth.uid)

apps/{appId}/service_providers/{providerId}:
  read:   any authenticated user
  write:  only owner (providerId == auth.uid)

apps/{appId}/packages/{packageId}:
  read:   any authenticated user
  create: any authenticated user
  update/delete: only owner (resource.data.providerId == auth.uid)

apps/{appId}/addons/{addonId}:
  read:   any authenticated user
  write:  admin only (for now)

apps/{appId}/schedule_configs/{configId}:
  read:   any authenticated user
  create: any authenticated user
  update/delete: only owner (resource.data.providerId == auth.uid)

apps/{appId}/slots/{slotId}:
  read:   any authenticated user
  create: any authenticated user
  update/delete: only owner (resource.data.providerId == auth.uid)

apps/{appId}/bookings/{bookingId}:
  read:   userId OR providerId match auth.uid
  create: any authenticated user
  update: userId OR providerId match auth.uid
  delete: only customer (resource.data.userId == auth.uid)
```

---

## 9. Field Naming Rules

Both apps **MUST** follow these conventions to avoid mismatches:

| Rule | Example |
|------|---------|
| camelCase for all field names | `providerId`, `totalPrice`, not `provider_id` |
| Timestamps use Firebase `Timestamp` type | `createdAt: Timestamp.fromDate(...)` |
| Dates stored as `Timestamp` with time = midnight | `date: Timestamp(2026-02-23 00:00:00)` |
| Time strings use `"HH:mm"` format | `"08:00"`, `"14:30"` |
| Booleans default to `false` | `isDefault`, `isActive` |
| Arrays default to empty `[]` | `addonIds: []` |
| Nullable fields → `null` not empty string | `branchId: null` NOT `branchId: ""` |

---

## 10. Migration Notes

> **⚠️ IMPORTANT for both developers**

### Path Migration
- ❌ **OLD:** `tenants/{appId}/...`
- ✅ **NEW:** `apps/{appId}/...`

### Collection Name Consolidation
- ❌ `vehicles` collection → ✅ Use `cars` everywhere
- ❌ `servicePackages` collection → ✅ Use `packages` everywhere
- ❌ `availability/*/slots` subcollection → ✅ Use root-level `slots` collection
- ❌ `centers` and `branches` → ✅ Use `service_providers` (with `geo` field)

### Field Name Consolidation
- ❌ `durationMinutes` in Firestore → ✅ Use `duration` (the model reads `data['duration']`)
- ❌ `fullName` → ✅ Use `name`
- ❌ `licensePlate` in vehicles → ✅ Use `plateNumber`
- ❌ `make` in vehicles → ✅ Use `brand`

---

## Quick Example: Both Apps Querying Firestore

### Client App — Fetching available slots

```dart
// Client: Get today's slots for a specific provider
FirebaseFirestore.instance
  .collection('apps')
  .doc(AppConfig.appId)
  .collection('slots')
  .where('providerId', isEqualTo: selectedProviderId)
  .where('date', isEqualTo: todayTimestamp)
  .get();
```

### Provider App — Fetching incoming bookings

```dart
// Provider: Get my pending bookings
FirebaseFirestore.instance
  .collection('apps')
  .doc(AppConfig.appId)
  .collection('bookings')
  .where('providerId', isEqualTo: myUid)
  .where('status', isEqualTo: 'pending')
  .orderBy('createdAt', descending: true)
  .get();
```

### Client App — Creating a booking

```dart
// Client: Create a new booking
FirebaseFirestore.instance
  .collection('apps')
  .doc(AppConfig.appId)
  .collection('bookings')
  .add({
    'appId': AppConfig.appId,
    'userId': currentUser.uid,
    'providerId': selectedProviderId,  // ← CRITICAL!
    'vehicleId': selectedCarId,
    'centerId': selectedProviderId,
    'serviceType': 'inCenter',
    'packageId': selectedPackageId,
    'addonIds': selectedAddonIds,
    'scheduledDate': Timestamp.fromDate(selectedDate),
    'timeSlot': '10:00',
    'status': 'pending',
    'totalPrice': calculatedTotal,
    'currency': 'EGP',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
```

---

> **Both developers: bookmark this file. Any new collection or field goes here first, then into code.**
