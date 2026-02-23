# Slot Generation - Debug Guide

## 🔍 Problem

Slots are not being created in Firebase after clicking "Generate Slots" button.

## ✅ What We Know

1. **Schedule Config IS Being Saved** ✓
   - Visible in: `/apps/shine_wash/schedule_configs/`
   - Contains: capacity, working hours, date range, off days

2. **Slots Collection Does NOT Exist** ❌
   - Expected: `/apps/shine_wash/slots/`
   - Status: Not appearing in Firebase Console

## 🔬 Debugging Steps

### Step 1: Run Provider App with Console Open

```bash
cd /Users/imbaby/Desktop/Washing-Cars/washing_car
flutter run -t lib/main_provider.dart
```

**Keep terminal visible** - we've added extensive logging!

### Step 2: Navigate to "Add Slot" Page

1. Login to provider account
2. Go to "Add Slot / إضافة موعد"

### Step 3: Configure Schedule

Example settings:
- Washing Capacity: 3
- From Date: Feb 10, 2026
- To Date: Feb 20, 2026
- Working Hours: 08:00 - 22:00
- Off Days: Friday (5) ✓
- Slot Duration: 30 min

### Step 4: Save Configuration

Click **"Save Configuration / حفظ الإعدادات"**

**Watch console** - you should see Firestore activity

### Step 5: Generate Slots

Click **"Generate Slots / إنشاء المواعيد"**

**Watch console carefully** - you should see:

```
🔵 Starting slot generation for provider: <providerId>
✅ Config loaded: <configId>
📅 Date range: 2026-02-10 to 2026-02-20
⏰ Working hours: TimeOfDay(08:00) to TimeOfDay(22:00)
🚫 Off days: [5]
🚗 Capacity: 3
⏱️ Slot duration: 30 minutes
📝 Processing 2026-02-10 (weekday 1)...
   ➡️ Generated 28 time slots for this day
   💾 Saving to Firestore with ID: <providerId>_20260210
   📦 Collection path: apps/shine_wash/slots
   ✅ Saved successfully!
...
🎉 Total: 9 slot documents created for 9 working days
🔄 Updating lastGenerated timestamp...
✅ lastGenerated updated
```

## 🚨 Possible Errors & Solutions

### Error 1: "Schedule configuration not found"

**Console shows:**
```
❌ No config found for provider: <providerId>
```

**Solution:**
- Click "Save Configuration" FIRST
- Then click "Generate Slots"

---

### Error 2: Firebase Permission Denied

**Console shows:**
```
❌ ERROR generating slots: [cloud_firestore/permission-denied]
```

**Solution:**
Check Firebase Security Rules for `/apps/{appId}/slots`:

```javascript
match /apps/{appId}/slots/{slotId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

**Fix in Firebase Console:**
1. Go to Firestore Database
2. Click "Rules" tab
3. Add the above rule
4. Publish changes

---

### Error 3: App ID Mismatch

**Console shows:**
```
📦 Collection path: apps/default_tenant/slots
```

But your Firebase shows: `/apps/shine_wash/`

**Solution:**
Update `app_config.dart`:

```dart
class AppConfig {
  static String appId = 'shine_wash'; // ← Change this
}
```

---

### Error 4: Date Range is Empty

**Console shows:**
```
🎉 Total: 0 slot documents created for 0 working days
```

**Possible causes:**
- All days in range are marked as off days
- Date range Start >= End
- Working hours Start >= End

**Solution:**
- Uncheck at least some weekdays
- Verify From Date < To Date
- Verify Start Time < End Time

---

### Error 5: Silent Failure (No Console Output)

**Nothing appears in console after clicking button**

**Solution:**
1. Check if `_providerId` is null:
   ```dart
   void _generateSlots() {
     if (_providerId == null) return; // ← Fails silently here
     ...
   }
   ```

2. Verify user is logged in:
   ```dart
   FirebaseAuth.instance.currentUser; // Should not be null
   ```

3. Restart app and login again

---

## 🧪 Manual Test in Firebase Console

If app isn't working, test Firestore access directly:

### Test 1: Can You Read schedule_configs?

1. Open Firebase Console
2. Go to Firestore Database
3. Navigate to: `apps/shine_wash/schedule_configs/<documentId>`
4. Click "Edit document"
5. Can you see the data? ✅ Read permission OK

### Test 2: Can You Create slots Document Manually?

1. In Firestore Console, click "Start collection"
2. Collection ID: `slots` (inside `apps/shine_wash/`)
3. Document ID: `test_slot`
4. Add fields:
   - `providerId` (string): your user ID
   - `appId` (string): `shine_wash`
   - `date` (timestamp): today
   - `capacity` (number): 3
5. Click "Save"

**If this fails** → Permission issue in Security Rules
**If this works** → Issue is in the app code

---

## 📋 Checklist Before Testing

- [ ] Firebase Authentication enabled
- [ ] User is logged in as Service Provider
- [ ] `AppConfig.appId` matches Firebase collection path
- [ ] Firestore Security Rules allow write to `slots` collection
- [ ] Schedule configuration has been saved
- [ ] Date range is valid (From < To)
- [ ] At least one weekday is NOT in off days
- [ ] Working hours are valid (Start < End)
- [ ] Console/terminal is visible while testing

---

## 🎯 Expected Firestore Structure After Success

```
/apps
  /shine_wash
    /schedule_configs
      /1707313999448
        providerId: "MYwYYqYaGp2IdxXagxmQPG4RT2"
        appId: "shine_wash"
        washingCapacity: 3
        workingStartTime: "08:00"
        workingEndTime: "22:00"
        offDays: [5]
        dateRangeStart: Feb 10, 2026
        dateRangeEnd: Feb 20, 2026
        slotDurationMinutes: 30
        lastGenerated: Feb 10, 2026 12:30 PM  ← Updated after generation

    /slots  ← THIS COLLECTION SHOULD APPEAR
      /MYwYYqYaGp2IdxXagxmQPG4RT2_20260210
        providerId: "MYwYYqYaGp2IdxXagxmQPG4RT2"
        appId: "shine_wash"
        date: Feb 10, 2026
        slots: [
          { time: "08:00", capacity: 3, booked: 0 },
          { time: "08:30", capacity: 3, booked: 0 },
          ...
        ]
        createdAt: Feb 10, 2026 12:30 PM

      /MYwYYqYaGp2IdxXagxmQPG4RT2_20260211
        ... (same structure)

      ... (one document per working day)
```

---

## 📞 Next Steps If Still Not Working

1. **Share console output** from Step 5 above
2. **Share Firebase Security Rules** (Firestore → Rules tab)
3. **Share `AppConfig.appId` value**
4. **Share screenshot** of Firebase Console showing collections

We'll diagnose the exact issue together!

---

**Last Updated:** Feb 10, 2026
