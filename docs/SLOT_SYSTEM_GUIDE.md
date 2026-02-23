# Slot System - Complete Guide

## Overview

The slot system has been completely rebuilt with a simplified date range approach. Here's how it works:

## 🎯 Features Implemented

### 1. **Add Slot Page** (Simplified Configuration)
**Route**: `/add-slot` or "إضافة موعد"

**What it does**:
- Configure your washing schedule once
- Automatically generate hundreds of slots for any date range
- Set capacity, working hours, off days, and slot duration

**How to use**:
1. **Set Washing Capacity**: How many cars you can wash simultaneously (1-10)
2. **Select Date Range**: Choose From and To dates (e.g., Feb 10 → Mar 10)
3. **Set Working Hours**: Start and end time for ALL days (e.g., 8 AM - 10 PM)
4. **Choose Off Days**: Select which weekdays to exclude (e.g., Friday, Sunday)
5. **Set Slot Duration**: Default 30 minutes (adjustable: 15-120 min)
6. **Preview**: See total working days, slots per day, total slots
7. **Click "Save Configuration"**: Saves your settings
8. **Click "Generate Slots"**: Creates all slots in Firestore

### 2. **My Slots Page** (View & Monitor)
**Route**: `/my-slots` or "مواعيدي"

**What it shows**:
- All created slots organized by date
- Booking status for each slot
- Capacity indicators (available, booked, full)
- Detailed information when you tap a slot

**Features**:
- 📅 **Calendar View**: Slots grouped by date
- 🟢 **Status Indicators**: 
  - Green = Available
  - Orange = Partially booked
  - Red = Fully booked
- 📊 **Statistics**: Shows available vs booked slots per day
- 🔍 **Slot Details**: Tap any slot to see:
  - Capacity
  - How many booked
  - How many available
- 🔄 **Refresh**: Pull to refresh or tap refresh icon

## 📋 Step-by-Step Usage

### First Time Setup

**Step 1: Configure Schedule**
```
Navigate to: Add Slot (إضافة موعد)

Example Configuration:
- Capacity: 3 cars
- From: Feb 10, 2026
- To: Mar 10, 2026
- Working Hours: 8:00 AM - 10:00 PM
- Off Days: Friday, Sunday ✓
- Slot Duration: 30 minutes

Preview shows: 21 working days × 28 slots = 588 total slots
```

**Step 2: Save Configuration**
```
Click: "Save Configuration / حفظ الإعدادات"
Wait for: Success message (green snackbar)
```

**Step 3: Generate Slots**
```
Click: "Generate Slots / إنشاء المواعيد"
Wait for: Generation progress (may take a few seconds)
Success: Green message + auto-navigate back
```

**Step 4: View Created Slots**
```
Navigate to: My Slots (مواعيدي)
You'll see: All dates with slots
Tap a date: Expands to show all time slots
Tap a slot: Shows detailed booking information
```

## 🗄️ Firestore Structure

### Schedule Configs
**Collection**: `/apps/{app_id}/schedule_configs/{configId}`

```json
{
  "providerId": "provider123",
  "appId": "shine_wash",
  "washingCapacity": 3,
  "workingStartTime": "08:00",
  "workingEndTime": "22:00",
  "offDays": [5, 7],
  "dateRangeStart": "2026-02-10",
  "dateRangeEnd": "2026-03-10",
  "slotDurationMinutes": 30,
  "createdAt": timestamp,
  "lastGenerated": timestamp
}
```

### Generated Slots
**Collection**: `/apps/{app_id}/slots/{slotId}`

```json
{
  "providerId": "provider123",
  "appId": "shine_wash",
  "date": "2026-02-10",
  "slots": [
    {
      "time": "08:00",
      "capacity": 3,
      "booked": 0
    },
    {
      "time": "08:30",
      "capacity": 3,
      "booked": 2
    },
    {
      "time": "09:00",
      "capacity": 3,
      "booked": 3
    }
    // ... 28 slots per day
  ],
  "createdAt": timestamp
}
```

## 🎨 UI Components

### Add Slot Page Components
1. **CapacityConfigWidget**: +/- buttons for capacity
2. **DateRangePickerWidget**: From/To date selectors
3. **WorkingHoursWidget**: Start/End time pickers
4. **OffDaysSelectorWidget**: Weekday checkboxes
5. **Slot Duration**: Adjustable with +/- buttons
6. **Preview Card**: Real-time calculation display

### My Slots Page Components
1. **SlotDayCard**: Collapsible date card with summary
2. **TimeSlotChip**: Color-coded slot status chips
3. **Booking Details Modal**: Bottom sheet with slot info
4. **Status Badges**: Available/Booked indicators

## 🔄 Booking Flow

### When Customer Books:
1. Customer selects package (e.g., Premium Wash - 60 min)
2. Selects date and time slot (e.g., Feb 10, 10:00 AM)
3. System calculates slots needed (60 min ÷ 30 = 2 slots)
4. Checks availability: 10:00 and 10:30 slots
5. If available, increments `booked` count for both slots
6. Creates booking record

### Example:
```
Before booking:
{
  "time": "10:00", "capacity": 3, "booked": 1
}
{
  "time": "10:30", "capacity": 3, "booked": 1
}

After booking (60-min service):
{
  "time": "10:00", "capacity": 3, "booked": 2  ← +1
}
{
  "time": "10:30", "capacity": 3, "booked": 2  ← +1
}
```

## 🐛 Troubleshooting

### "No slots created yet"
**Solution**: 
1. Go to Add Slot page
2. Configure settings
3. Click "Save Configuration"
4. Click "Generate Slots"

### Slots not showing in My Slots
**Solution**:
1. Check Firebase Console: `/apps/{app_id}/slots/`
2. Verify providerId matches your user ID
3. Tap refresh icon in My Slots page
4. Regenerate slots if needed

### Wrong number of slots generated
**Solution**:
1. Check off days selection
2. Verify date range
3. Confirm working hours and slot duration
4. Recalculate: `(working hours × 60 ÷ slot duration) × working days`

### Can't see booking details
**Current Status**: The modal shows slot capacity/availability
**To see customer details**: Navigate to "My Bookings" page (separate feature)

## 📱 Navigation Routes

| Route | Page | Purpose |
|-------|------|---------|
| `/add-slot` | Add Slot | Configure & generate slots |
| `/my-slots` | My Slots | View all created slots |
| `/schedule-config` | Schedule Config | Alternative config page |
| `/my-bookings` | My Bookings | View customer bookings |

## ✅ What Works Now

- ✅ Date range selection (From/To)
- ✅ Single working hours for all days
- ✅ Off days exclusion
- ✅ 30-minute default slots (adjustable)
- ✅ Automatic slot generation
- ✅ View all slots by date
- ✅ Color-coded availability status
- ✅ Slot detail modal
- ✅ Booking status tracking (booked count)
- ✅ Capacity indicators
- ✅ Bilingual UI (Arabic/English)

## 🎯 Next Steps

To view **WHO booked each slot**, you need to:
1. Query the `/apps/{app_id}/bookings` collection
2. Match `bookingData.timeSlot` with slot time
3. Get customer details from booking record

This requires updating the slot detail modal to fetch and display booking records. Would you like me to implement this?

## 🔧 Technical Notes

- Slots generate at **30-minute intervals** (configurable)
- Booking uses **Firestore transactions** to prevent race conditions
- Each slot tracks **individual booking count**
- Multiple customers can book **same slot** if capacity allows
- Provider can **update capacity** (affects future slots only)
- Old slots don't auto-delete (manual cleanup needed)

---

**Created**: Feb 10, 2026  
**Version**: 2.0 (Simplified Date Range System)
