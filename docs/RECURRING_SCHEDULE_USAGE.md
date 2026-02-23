# Simplified Date Range Scheduling - Usage Guide

## Overview

The simplified scheduling system allows service providers to easily configure their availability and automatically generate time slots for any date range with consistent working hours across all days.

## Key Features

- **Single Working Hours**: Set one working schedule (e.g., 8 AM - 10 PM) that applies to all working days
- **Custom Date Range**: Generate slots for any period (e.g., Feb 10 to Mar 10)
- **Off Days Selection**: Choose which weekdays to exclude (e.g., Friday and Sunday)
- **30-Minute Slots**: Default slot duration with adjustable intervals (15, 30, 45, 60, 90, 120 minutes)
- **Capacity Management**: Set how many cars can be washed simultaneously
- **Automatic Generation**: One-click slot creation for the entire date range

## For Service Providers

### Step 1: Configure Your Schedule

Navigate to **Schedule Configuration** from the provider dashboard.

#### 1. Set Washing Capacity
- Use the +/- buttons to set how many cars you can wash at the same time
- Range: 1-10 cars per time slot
- Example: If you have 3 washing bays, set capacity to 3

#### 2. Select Date Range
- **From**: Start date for slot generation (e.g., Feb 10, 2026)
- **To**: End date for slot generation (e.g., Mar 10, 2026)
- You can select any date range from today up to 1 year ahead

#### 3. Set Working Hours
- **Start Time**: When you begin accepting customers (e.g., 8:00 AM)
- **End Time**: When you stop accepting customers (e.g., 10:00 PM)
- These hours apply to **all working days**

#### 4. Select Off Days
- Check the days you want to **exclude** from slot generation
- Examples:
  - Weekend off: Check Saturday and Sunday
  - Friday off: Check Friday only
  - Custom: Any combination of weekdays

#### 5. Configure Slot Duration
- Default: 30 minutes per slot
- Adjustable: 15, 30, 45, 60, 90, or 120 minutes
- Use +/- buttons to change

### Step 2: Preview and Generate

The system shows a real-time preview:
- **Working days**: Total days excluding off days
- **Slots per day**: Based on working hours and slot duration
- **Total slots**: Complete count to be generated

Click **"Generate Slots"** to create all time slots for the selected date range.

## Example Configuration

```
Washing Capacity: 3 cars
Date Range: Feb 10, 2026 → Mar 10, 2026 (29 days)
Working Hours: 8:00 AM → 10:00 PM (14 hours)
Off Days: Friday, Sunday
Slot Duration: 30 minutes

Preview:
• Working days: 21 days (29 total - 4 Fridays - 4 Sundays)
• Slots per day: 28 slots (14 hours × 2 per hour)
• Total slots: 588 slots
```

## Generated Slot Example

For **February 10, 2026 (Monday)**:
```
08:00 - 08:30  [3 spots available]
08:30 - 09:00  [3 spots available]
09:00 - 09:30  [3 spots available]
...
21:00 - 21:30  [3 spots available]
21:30 - 22:00  [3 spots available]
```

For **February 14, 2026 (Friday)**: SKIPPED (off day)

## For Customers

### Enhanced Slot Selection

When booking a service, customers see:

1. **Time Slot**: Start time (e.g., "10:00 AM")
2. **Duration Indicator**: Service duration (e.g., "Until 11:00 AM")
3. **Capacity Status**:
   - "3 spots available" (Full capacity)
   - "2 spots left" (Partially booked)
   - "Last spot!" (Almost full)
   - Disabled (Fully booked)

### Smart Filtering

The system only shows slots where:
- All consecutive slots needed for the service are available
- Service fits within working hours
- Provider has capacity

### Example Customer Booking

**Selected Package**: Premium Wash (60 minutes)

**Available Times**:
- 10:00 AM → Until 11:00 AM [2 spots left]
- 11:00 AM → Until 12:00 PM [3 spots available]
- 2:00 PM → Until 3:00 PM [Last spot!]

When customer books 10:00 AM:
- System reserves: 10:00-10:30 and 10:30-11:00 (2 consecutive 30-min slots)
- Each slot's booked count increments by 1
- Confirmation shows: "Service from 10:00 AM to 11:00 AM"

## Technical Details

### Database Structure

**Schedule Config**: `/apps/{app_id}/schedule_configs/{configId}`
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

**Slots**: `/apps/{app_id}/slots/{slotId}`
```json
{
  "providerId": "provider123",
  "appId": "shine_wash",
  "date": "2026-02-10",
  "slots": [
    {"time": "08:00", "capacity": 3, "booked": 0},
    {"time": "08:30", "capacity": 3, "booked": 1},
    {"time": "09:00", "capacity": 3, "booked": 2},
    ...
  ],
  "createdAt": timestamp
}
```

### Slot Generation Algorithm

```
1. For each date from dateRangeStart to dateRangeEnd:
   a. Check if date.weekday is NOT in offDays list
   b. If working day:
      - Generate slots from workingStartTime to workingEndTime
      - Use slotDurationMinutes as interval (default 30 min)
      - Set capacity from config
      - Initialize booked count to 0
   c. Save slot document to Firestore
2. Update config.lastGenerated timestamp
```

### Booking Algorithm

```
1. Customer selects package with duration (e.g., 60 minutes)
2. Calculate slots needed: duration ÷ slotDurationMinutes (60 ÷ 30 = 2 slots)
3. Find consecutive available slots
4. Use Firestore transaction:
   a. Read slot document
   b. Verify all required slots have capacity (booked < capacity)
   c. If available, increment booked count for each slot
   d. Create booking record
5. If any slot is full, booking fails with error message
```

## Benefits

### For Service Providers
✅ **Simple Setup**: Configure once, generate for entire period  
✅ **No Manual Work**: Automatic slot creation  
✅ **Flexible Scheduling**: Adjust capacity and hours anytime  
✅ **Prevent Overbooking**: Automatic capacity tracking  
✅ **Clear Overview**: Preview before generation  

### For Customers
✅ **Real-Time Availability**: See actual capacity status  
✅ **Smart Filtering**: Only see bookable time slots  
✅ **Clear Duration**: Know exact service time window  
✅ **Instant Booking**: Guaranteed reservation  

## Tips & Best Practices

1. **Set Realistic Capacity**: Consider:
   - Number of washing bays
   - Staff availability
   - Service complexity

2. **Choose Appropriate Slot Duration**:
   - 30 min: Standard washes
   - 60 min: Premium services
   - 90-120 min: Detailing services

3. **Plan Date Ranges**:
   - Generate at least 1 month ahead
   - Regenerate monthly for continuous availability
   - Adjust for holidays and special events

4. **Monitor and Adjust**:
   - Check booking patterns
   - Adjust working hours based on demand
   - Update capacity as business grows

5. **Off Days Strategy**:
   - Religious holidays (e.g., Friday for Muslim providers)
   - Weekly rest days
   - Maintenance days

## Troubleshooting

**Q: Slots not appearing for customers?**  
A: Ensure you clicked "Generate Slots" after saving configuration

**Q: Too many/few slots generated?**  
A: Adjust slot duration (15-120 minutes) and regenerate

**Q: Want to change working hours?**  
A: Update configuration and regenerate slots (old slots remain until date passes)

**Q: Customer can't book preferred time?**  
A: Check if:
  - Day is marked as off day
  - Capacity is fully booked
  - Package duration exceeds available consecutive slots

## Support

For technical issues or feature requests, contact your platform administrator.
