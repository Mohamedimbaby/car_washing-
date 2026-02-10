# Quick Test Guide - Booking System 🚀

## 🎯 Test the Complete Booking Flow (5 Minutes)

### Prerequisites
- Flutter installed
- Firebase configured (or use mock data)
- App running: `flutter run`

---

## 📱 Test Scenario 1: Guest User Booking

### Steps:
1. **Open App**
   - App opens to splash screen
   - Redirects to login page

2. **Continue as Guest**
   - Tap **"Continue as Guest"** button
   - App navigates to Home page
   - Notice "GUEST" badge and banner at top

3. **Select Service Type**
   - Tap **"Wash at Center"** card
   - Navigates to Package Selection page

4. **Choose Package**
   - See 4 packages: Basic ($25), Standard ($45), Premium ($75), Detailing ($150)
   - Each shows features, duration, and price
   - Tap any package (e.g., **"Premium Wash"**)

5. **Select Add-ons** (Optional)
   - See optional add-ons listed
   - Check any add-ons you want (e.g., "Wax Protection" +$15)
   - Notice total price updates automatically
   - Tap **"Continue"** button

6. **Pick Date & Time**
   - Default date is today
   - Use calendar icon to pick a different date
   - Or use ← → arrows to navigate days
   - Select an available time slot (green chips)
   - Tap **"Confirm Booking"**

7. **Success!**
   - See success confirmation page ✅
   - Tap **"View My Bookings"**

8. **View Booking History**
   - See your newly created booking
   - Notice status badge: **"Pending"** (yellow)
   - See total price, date, and time

### Expected Result: ✅
- Booking created successfully
- Stored in Firebase under `tenants/default_tenant/bookings/`
- Appears in booking history
- All data persists across app restarts

---

## 📱 Test Scenario 2: Authenticated User Booking

### Steps:
1. **Register Account**
   - Tap "Sign Up" on login page
   - Enter email, password, full name
   - Tap **"Register"**

2. **Complete Booking**
   - Follow same steps as Guest User (above)
   - Your bookings are now tied to your user account

3. **Verify**
   - Restart app
   - Should automatically log you in
   - See "My Bookings" with your history

---

## 🧪 Test Cases

### ✅ Core Functionality
- [ ] Guest mode works
- [ ] Login/Registration works
- [ ] Can select all 4 package types
- [ ] Can add multiple add-ons
- [ ] Price calculates correctly
- [ ] Can pick any future date
- [ ] Can select available time slots
- [ ] Booking creation succeeds
- [ ] Booking appears in history
- [ ] Booking persists after app restart

### ✅ UI/UX
- [ ] All pages load quickly
- [ ] Loading indicators show during data fetch
- [ ] Error messages display on failures
- [ ] Success page shows after booking
- [ ] Navigation flows smoothly
- [ ] Back button works correctly
- [ ] Status badges show correct colors

### ✅ Edge Cases
- [ ] Selecting no add-ons (should work)
- [ ] Booking with special instructions
- [ ] Booking for same time slot twice
- [ ] Empty booking history (shows "No bookings yet")
- [ ] Network failure (shows error with retry)

---

## 📊 What to Check in Firebase Console

### After Creating a Booking:

1. **Open Firebase Console**
   - Go to Firestore Database

2. **Navigate to Path:**
   ```
   tenants → default_tenant → bookings → {bookingId}
   ```

3. **Verify Fields:**
   - `userId`: Your user ID or "guest"
   - `packageId`: Selected package ID
   - `addonIds`: Array of selected addon IDs
   - `scheduledDate`: Timestamp of selected date
   - `timeSlot`: Selected time (e.g., "10:00")
   - `status`: "pending"
   - `totalPrice`: Calculated total (number)
   - `createdAt`: Timestamp

---

## 🎨 UI Elements to Test

### Package Selection Page
- [ ] Package cards display correctly
- [ ] Price formatting is correct ($25.00)
- [ ] Features list shows checkmarks
- [ ] Duration shows (e.g., "~60 min")
- [ ] Tapping card navigates forward

### Add-on Selection Page
- [ ] Package summary shows at top
- [ ] Add-on checkboxes work
- [ ] Total price updates live
- [ ] Continue button is always enabled

### Time Slot Selection Page
- [ ] Date selector shows current date
- [ ] Calendar picker opens
- [ ] Time slots display as chips
- [ ] Selected slot highlights in blue
- [ ] Unavailable slots are disabled (gray)
- [ ] Confirm button only works when slot selected

### Booking History Page
- [ ] Pull-to-refresh works
- [ ] Empty state shows when no bookings
- [ ] Booking cards show all info
- [ ] Status badges have correct colors:
  - 🟡 Pending (yellow)
  - 🔵 Confirmed (blue)
  - 🟣 In Progress (purple)
  - 🟢 Completed (green)
  - 🔴 Cancelled (red)

---

## 🐛 Common Issues & Fixes

### Issue: "Firebase not configured"
**Fix:** The app uses mock data by default. To use Firebase:
1. Follow `FIREBASE_SETUP.md`
2. Add `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)

### Issue: "No packages showing"
**Fix:** This is expected! Mock data will show automatically. To add real data:
1. Open Firebase Console
2. Create collection: `tenants/default_tenant/servicePackages`
3. Add documents with package data (see `FIREBASE_MULTI_TENANT_STRUCTURE.md`)

### Issue: "Bookings not persisting"
**Check:**
1. Firebase is initialized in `main.dart`
2. User is authenticated or in guest mode
3. Internet connection is active
4. Check Firebase Console for security rule issues

### Issue: "App crashes on booking"
**Check:**
1. Run `flutter pub get`
2. Check terminal for error messages
3. Verify all dependencies are installed
4. Try `flutter clean && flutter pub get`

---

## 🎯 Success Criteria

### You know it's working when:
✅ Can create booking as guest  
✅ Can create booking as authenticated user  
✅ Booking appears in Firebase Console  
✅ Booking shows in "My Bookings"  
✅ Price calculates correctly  
✅ Status badge shows "Pending"  
✅ All UI elements render properly  

---

## 📸 Screenshots to Take

While testing, capture:
1. Home page with service cards
2. Package selection with all 4 packages
3. Add-on selection with price updating
4. Time slot selection with calendar
5. Success confirmation page
6. Booking history with entries
7. Firebase Console showing booking data

---

## ⚡ Quick Commands

```bash
# Run app
flutter run

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Check for issues
flutter doctor
flutter analyze

# View logs
flutter logs
```

---

## 🎉 Congratulations!

If all tests pass, your booking system is **fully operational**! 

### What's Next?
- ✅ Booking module complete
- ⏳ Add vehicle management
- ⏳ Add center selection with maps
- ⏳ Integrate payment gateway
- ⏳ Add push notifications

### Questions?
Check the documentation:
- `BOOKING_MODULE_COMPLETE.md` - Full booking guide
- `FIREBASE_MULTI_TENANT_STRUCTURE.md` - Database schema
- `IMPLEMENTATION_STATUS.md` - Overall progress

---

**Happy Testing! 🚗✨**
