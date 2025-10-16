# Timezone and Video Calling Fixes

## Overview

Fixed critical timezone issues and added video call status updates for real-time doctor notifications.

## Issues Fixed

### 1. ❌ Problem: 6-Hour Time Offset

**Symptom:** Appointments showed "6h remaining" when they should show "2m remaining"

**Root Cause:**

- Booking form created DateTime in local time (Dhaka, UTC+6)
- Saved to database without converting to UTC
- Database stored `22:30:00+00` (treating local time AS UTC)
- When read back, showed 6 hours in the future

**Solution:**

```dart
// Before (wrong)
'scheduled_time': scheduledTime.toIso8601String()

// After (correct)
'scheduled_time': scheduledTime.toUtc().toIso8601String()
```

### 2. ❌ Problem: New Schedules Not Showing

**Symptom:** Newly booked consultations didn't appear in the home page list

**Root Cause:**

- Query filter used local time: `DateTime.now().toIso8601String()`
- Database has UTC times, compared with local time string
- Filter excluded valid appointments

**Solution:**

```dart
// Before (wrong)
.gte('scheduled_time', DateTime.now().toIso8601String())

// After (correct)
.gte('scheduled_time', DateTime.now().toUtc().toIso8601String())
```

### 3. ❌ Problem: Display Time Wrong

**Symptom:** UI showed UTC time instead of Dhaka local time

**Root Cause:**

- Display formatter used UTC DateTime directly
- Users saw "8:00 AM" instead of "2:00 PM"

**Solution:**

```dart
// Before (wrong)
dateFormatter.format(consultation.scheduledTime)

// After (correct)
dateFormatter.format(consultation.scheduledTime.toLocal())
```

## New Feature: Video Call Status Updates

### Implementation

When patient initiates a video call, the consultation status is automatically updated in Supabase to notify the doctor.

**Code Location:** `lib/features/video_call/presentation/providers/video_call_provider.dart`

```dart
/// Update consultation status to 'calling' when patient initiates the call
Future<void> _updateConsultationStatus() async {
  try {
    final supabase = Supabase.instance.client;

    await supabase
        .from('consultations')
        .update({
          'consultation_status': 'calling',  // ← Triggers incoming call on doctor side!
          'agora_channel_name': AgoraConfig.channelName,
          'agora_token': AgoraConfig.token,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', callInfo.consultationId);

    print('✅ Updated consultation status to calling');
  } catch (e) {
    print('❌ Error updating consultation status: $e');
    // Don't throw - allow call to proceed even if status update fails
  }
}
```

### How It Works

1. Patient clicks "Join Video Call" button
2. `initializeCall()` is called
3. Consultation status updated to `'calling'` in database
4. Doctor app (listening to database changes) receives notification
5. Doctor sees incoming call UI
6. Agora channel name and token are shared for connection

### Database Schema Requirements

Ensure your `consultations` table has these columns:

```sql
- consultation_status (text)
- agora_channel_name (text, nullable)
- agora_token (text, nullable)
- updated_at (timestamp with time zone)
```

## Files Modified

### 1. `lib/features/consult/data/repositories/doctor_repository.dart`

- **Line 125:** Added `.toUtc()` before saving scheduled time
- **Impact:** All new bookings now store correct UTC time

### 2. `lib/features/home/presentation/widgets/home_widgets.dart`

- **Line 170:** Added `.toLocal()` when formatting display time
- **Impact:** Users see appointments in their local timezone

### 3. `lib/features/home/presentation/providers/consultation_provider.dart`

- **Line 87:** Added `.toUtc()` in query filter
- **Impact:** New appointments appear immediately in list

### 4. `lib/features/video_call/presentation/providers/video_call_provider.dart`

- **Added:** `_updateConsultationStatus()` method
- **Modified:** `initializeCall()` to update status before joining
- **Impact:** Doctor receives real-time call notifications

## Testing

### Test Scenario 1: Book Appointment

```
1. Open consult page
2. Select tomorrow, 2:00 PM
3. Click "Book Consultation"
4. Check database - should show UTC time (8:00 AM UTC = 2:00 PM Dhaka)
5. Check home page - should show "2:00 PM" in appointment card
```

### Test Scenario 2: Time Remaining

```
1. Book appointment for 2 minutes from now
2. Should show "Available in 2m" (not "6h")
3. Wait until within 15 minutes
4. Should show "Join Video Call" button
```

### Test Scenario 3: Video Call Status

```
1. Open appointment with video call
2. Click "Join Video Call"
3. Check database - consultation_status should change to 'calling'
4. Doctor app should receive notification
```

## Important Notes

### ⚠️ Existing Data

Old consultations in the database may have incorrect timezone data. Options:

1. Delete and rebook them (recommended for testing)
2. Run SQL migration to fix them (see below)

### SQL Migration (Optional)

If you need to fix existing appointments:

```sql
-- Only for consultations that were booked with the bug
-- This subtracts 6 hours to convert from "wrong UTC" to actual UTC
UPDATE consultations
SET scheduled_time = scheduled_time - INTERVAL '6 hours'
WHERE scheduled_time > NOW() + INTERVAL '6 hours'
  AND created_at < '2025-10-15 17:00:00+00';  -- Before the fix
```

### Timezone Best Practices

**Golden Rules:**

1. ✅ **Store:** Always store in UTC
2. ✅ **Compare:** Always compare UTC to UTC
3. ✅ **Display:** Always display in user's local time
4. ✅ **Filter:** Always filter using UTC

**Example Flow:**

```dart
// When saving
final localTime = DateTime(2025, 10, 16, 14, 0);  // 2:00 PM local
final utcTime = localTime.toUtc();  // Convert to UTC
save(utcTime.toIso8601String());  // Save as UTC string

// When displaying
final dbTime = DateTime.parse(dbString);  // Parse as UTC
final localTime = dbTime.toLocal();  // Convert to local
display(localTime);  // Show to user

// When comparing
final now = DateTime.now().toUtc();  // Current time in UTC
final scheduled = dbTime.toUtc();  // Scheduled time in UTC
final diff = scheduled.difference(now);  // Compare UTC to UTC
```

## Verification

Run the comprehensive test:

```bash
dart run test_all_fixes.dart
```

All tests should pass with ✅ symbols showing correct behavior.

## Doctor App Integration

The doctor app should listen for consultation status changes:

```dart
// Example doctor app code
Supabase.instance.client
    .from('consultations')
    .stream(primaryKey: ['id'])
    .eq('doctor_id', currentDoctorId)
    .listen((data) {
      for (var consultation in data) {
        if (consultation['consultation_status'] == 'calling') {
          // Show incoming call UI
          showIncomingCallDialog(
            channelName: consultation['agora_channel_name'],
            token: consultation['agora_token'],
            patientName: consultation['patient_name'],
          );
        }
      }
    });
```

## Status Flow

```
scheduled → calling → in_progress → completed
    ↓          ↓           ↓            ↓
  Booked   Patient    Both in     Call
           calling    call        ended
```
