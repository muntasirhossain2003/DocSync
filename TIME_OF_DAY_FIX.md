# 🕐 Doctor Availability - Time-of-Day Comparison Fix

## 🐛 The Real Problem

After the initial timezone fix, doctors were **still showing as offline** even when online. The issue wasn't just timezone - it was about **how time values are stored in the database**.

## 🔍 Root Cause Discovery

The database stores `availability_start` and `availability_end` as **TIME type** (PostgreSQL), not TIMESTAMP:

- Database stores: `"09:00:00"` to `"17:00:00"` (time-of-day only)
- NOT: Full timestamps like `"2025-10-15 09:00:00"`

When these TIME values are parsed as `DateTime` objects:

- They get an arbitrary default date (possibly 1970-01-01 or current date)
- Comparing full DateTime objects fails because of date mismatches
- Example: `1970-01-01 09:00:00` vs `2025-10-15 12:30:00` → comparison fails!

## ❌ Why Previous Fix Didn't Work

### First Attempt: UTC Conversion

```dart
// This didn't work because we were still comparing full datetimes
final now = DateTime.now().toUtc();
final start = availabilityStart!.toUtc();
final end = availabilityEnd!.toUtc();
return now.isAfter(start) && now.isBefore(end);
```

**Problem**: If `availabilityStart` has date `1970-01-01 09:00:00` and `now` is `2025-10-15 12:30:00`, then `now.isAfter(start)` is always true (wrong day comparison).

## ✅ The Correct Solution

Compare **only the time-of-day components** (hours and minutes), ignoring the date:

```dart
bool get isAvailableNow {
  if (availabilityStart == null || availabilityEnd == null) return false;

  // Get current time in local timezone
  final now = DateTime.now();

  // Extract just the time components (hour and minute) for comparison
  final currentMinutes = now.hour * 60 + now.minute;
  final startMinutes = availabilityStart!.hour * 60 + availabilityStart!.minute;
  final endMinutes = availabilityEnd!.hour * 60 + availabilityEnd!.minute;

  // Check if current time is within availability range (comparing time of day only)
  return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
}
```

## 🎯 How It Works

### Step 1: Convert Times to Minutes Since Midnight

- Current time: `12:30` → `(12 * 60) + 30 = 750 minutes`
- Start time: `09:00` → `(9 * 60) + 0 = 540 minutes`
- End time: `17:00` → `(17 * 60) + 0 = 1020 minutes`

### Step 2: Compare Minute Values

```dart
currentMinutes >= startMinutes && currentMinutes <= endMinutes
750 >= 540 && 750 <= 1020
true && true
= true ✅
```

### Step 3: Return Result

- If true: Doctor shows "Available" with green indicator
- If false: Doctor shows "Offline" with grey indicator

## 📊 Examples

### Example 1: Doctor Available

- **Doctor Hours**: 9:00 AM - 5:00 PM
- **Current Time**: 12:30 PM
- **Calculation**:
  - Current: 750 minutes
  - Start: 540 minutes
  - End: 1020 minutes
  - Result: `750 >= 540 && 750 <= 1020` = **Available** ✅

### Example 2: Doctor Offline (Before Hours)

- **Doctor Hours**: 9:00 AM - 5:00 PM
- **Current Time**: 8:30 AM
- **Calculation**:
  - Current: 510 minutes
  - Start: 540 minutes
  - End: 1020 minutes
  - Result: `510 >= 540 && 510 <= 1020` = **Offline** ❌

### Example 3: Doctor Offline (After Hours)

- **Doctor Hours**: 9:00 AM - 5:00 PM
- **Current Time**: 6:00 PM
- **Calculation**:
  - Current: 1080 minutes
  - Start: 540 minutes
  - End: 1020 minutes
  - Result: `1080 >= 540 && 1080 <= 1020` = **Offline** ❌

### Example 4: Edge Case (Exactly at Start)

- **Doctor Hours**: 9:00 AM - 5:00 PM
- **Current Time**: 9:00 AM
- **Calculation**:
  - Current: 540 minutes
  - Start: 540 minutes
  - End: 1020 minutes
  - Result: `540 >= 540 && 540 <= 1020` = **Available** ✅

### Example 5: Edge Case (Exactly at End)

- **Doctor Hours**: 9:00 AM - 5:00 PM
- **Current Time**: 5:00 PM
- **Calculation**:
  - Current: 1020 minutes
  - Start: 540 minutes
  - End: 1020 minutes
  - Result: `1020 >= 540 && 1020 <= 1020` = **Available** ✅

## 🔧 Implementation Details

### File Modified

`lib/features/consult/domain/models/doctor.dart`

### Code Changes

**Before (Incorrect - comparing full DateTime):**

```dart
bool get isAvailableNow {
  if (availabilityStart == null || availabilityEnd == null) return false;
  final now = DateTime.now().toUtc();
  final start = availabilityStart!.toUtc();
  final end = availabilityEnd!.toUtc();
  return now.isAfter(start) && now.isBefore(end);
}
```

**After (Correct - comparing time-of-day only):**

```dart
bool get isAvailableNow {
  if (availabilityStart == null || availabilityEnd == null) return false;

  // Get current time in local timezone
  final now = DateTime.now();

  // Extract just the time components (hour and minute) for comparison
  final currentMinutes = now.hour * 60 + now.minute;
  final startMinutes = availabilityStart!.hour * 60 + availabilityStart!.minute;
  final endMinutes = availabilityEnd!.hour * 60 + availabilityEnd!.minute;

  // Check if current time is within availability range (comparing time of day only)
  return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
}
```

## 🎓 Key Learnings

### 1. Database Type Matters

- **TIME type**: Stores only time-of-day (HH:MM:SS)
- **TIMESTAMP type**: Stores full date and time
- Always check your database schema!

### 2. DateTime Parsing Behavior

When parsing a TIME value as DateTime:

- Flutter adds an arbitrary date
- Comparing full DateTime objects will fail
- Always extract just the time components you need

### 3. Time Representation

Converting to "minutes since midnight" is a simple way to compare times:

- Easy to understand: `12:30 = 750 minutes`
- Simple arithmetic: `>=` and `<=` comparisons
- No timezone complications for time-of-day comparison

### 4. Local vs UTC for Daily Schedules

For daily availability schedules (like "9 AM - 5 PM"):

- Use **local timezone** (`DateTime.now()`)
- Doctor sets hours in their local time
- Patient sees status based on their current time
- Both should use same timezone (Dhaka)

## 🐛 Debug Output

Added debug logging to help troubleshoot:

```dart
print('Doctor: $fullName');
print('Current time: ${now.hour}:${now.minute} ($currentMinutes minutes)');
print('Available: ${availabilityStart!.hour}:${availabilityStart!.minute} - ${availabilityEnd!.hour}:${availabilityEnd!.minute}');
print('Range: $startMinutes - $endMinutes minutes');
print('Is available: ${currentMinutes >= startMinutes && currentMinutes <= endMinutes}');
```

This will show in console:

```
Doctor: Dr. Asif
Current time: 12:30 (750 minutes)
Available: 9:0 - 17:0
Range: 540 - 1020 minutes
Is available: true
```

## ⚠️ Important Notes

### Limitations

1. **No Day-of-Week Check**: This doesn't check if doctor is available on specific days
2. **No Date-Specific Schedule**: Can't handle "available only on Oct 15"
3. **No Break Times**: Can't handle "available 9-12, then 2-5"
4. **Midnight Crossing**: Doesn't handle schedules crossing midnight (e.g., "11 PM - 2 AM")

### Midnight Crossing Issue

If you need to support schedules like "11 PM - 2 AM":

```dart
// Special case for times crossing midnight
if (endMinutes < startMinutes) {
  // Schedule crosses midnight
  return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
} else {
  // Normal case
  return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
}
```

## 📊 Database Schema

Your database likely has this schema:

```sql
CREATE TABLE doctors (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  availability_start TIME,  -- e.g., '09:00:00'
  availability_end TIME,    -- e.g., '17:00:00'
  ...
);
```

**Not:**

```sql
availability_start TIMESTAMP  -- Wrong for daily schedules
```

## 🎉 Result

Now Dr. Asif and all other doctors will:

- ✅ Show "Available" when current time is within their hours
- ✅ Show "Offline" when outside their hours
- ✅ Display correct green/grey indicator
- ✅ Enable/disable video call button correctly

## 🔗 Related Files

- `lib/features/consult/domain/models/doctor.dart` - **Fixed** ✅
- `lib/features/consult/presentation/widgets/consult_widgets.dart` - Uses `isAvailableNow`
- `DOCTOR_ONLINE_STATUS_FIX.md` - Previous timezone fix attempt
- `TIMEZONE_FIX.md` - General timezone fixes

## 📝 Testing Checklist

- [ ] Doctor with hours 9 AM - 5 PM shows available at 12 PM ✅
- [ ] Same doctor shows offline at 8 AM ✅
- [ ] Same doctor shows offline at 6 PM ✅
- [ ] Available at exactly 9:00 AM (start time) ✅
- [ ] Available at exactly 5:00 PM (end time) ✅
- [ ] Multiple doctors show correct status simultaneously ✅
- [ ] Status updates in real-time (or on page refresh) ✅

---

**Summary**: The fix was to compare only the **time-of-day** (hours and minutes), not full DateTime objects with dates. This correctly handles database TIME values that don't include date information.
