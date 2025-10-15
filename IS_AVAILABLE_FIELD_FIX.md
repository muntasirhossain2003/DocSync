# 🟢 Doctor Availability - Using Database `is_available` Field

## ✅ Final Solution

The doctor availability status is now correctly using the **`is_available`** field from the database, which is managed by the backend based on:

- Doctor's online status (`is_online = true`)
- **OR**
- Doctor has defined availability schedule

## 🔄 How It Works

### Backend Logic (Database)

The `is_available` field is set by the backend using this logic:

```sql
-- Doctor is available if EITHER:
-- 1. They are currently online (is_online = true)
-- 2. OR they have a defined availability schedule

UPDATE doctors
SET is_available = true
WHERE (
    is_online = true
    OR
    (availability IS NOT NULL AND availability != '{}'::jsonb)
);
```

### Frontend (Flutter App)

The app simply reads the `is_available` field:

```dart
bool get isAvailableNow {
  return isAvailable;  // Directly from database
}
```

## 📝 Changes Made

### 1. Doctor Model (`lib/features/consult/domain/models/doctor.dart`)

**Added `isAvailable` field:**

```dart
class Doctor {
  final String id;
  final String userId;
  final String bmcdRegistrationNumber;
  final String specialization;
  final String? qualification;
  final double consultationFee;
  final DateTime? availabilityStart;
  final DateTime? availabilityEnd;
  final String? bio;
  final DateTime createdAt;
  final bool isAvailable;  // ← Added this field

  // User details from joined table
  final String fullName;
  final String? profilePictureUrl;
  final String email;

  Doctor({
    required this.id,
    required this.userId,
    required this.bmcdRegistrationNumber,
    required this.specialization,
    this.qualification,
    required this.consultationFee,
    this.availabilityStart,
    this.availabilityEnd,
    this.bio,
    required this.createdAt,
    required this.isAvailable,  // ← Required parameter
    required this.fullName,
    this.profilePictureUrl,
    required this.email,
  });
```

**Updated `fromJson` method:**

```dart
factory Doctor.fromJson(Map<String, dynamic> json) {
  return Doctor(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    bmcdRegistrationNumber: json['bmcd_registration_number'] as String,
    specialization: json['specialization'] as String? ?? 'General',
    qualification: json['qualification'] as String?,
    consultationFee: (json['consultation_fee'] as num).toDouble(),
    availabilityStart: json['availability_start'] != null
        ? DateTime.parse(json['availability_start'] as String)
        : null,
    availabilityEnd: json['availability_end'] != null
        ? DateTime.parse(json['availability_end'] as String)
        : null,
    bio: json['bio'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    isAvailable: json['is_available'] as bool? ?? false,  // ← Parse from JSON
    // User details from joined table
    fullName: json['users']?['full_name'] as String? ?? 'Doctor',
    profilePictureUrl: json['users']?['profile_picture_url'] as String?,
    email: json['users']?['email'] as String? ?? '',
  );
}
```

**Simplified `isAvailableNow` getter:**

```dart
// Before: Complex time calculation logic
bool get isAvailableNow {
  if (availabilityStart == null || availabilityEnd == null) return false;
  final now = DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;
  final startMinutes = availabilityStart!.hour * 60 + availabilityStart!.minute;
  final endMinutes = availabilityEnd!.hour * 60 + availabilityEnd!.minute;
  return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
}

// After: Simple database field access
bool get isAvailableNow {
  return isAvailable;  // Backend handles all logic
}
```

### 2. Consultation Provider (`lib/features/home/presentation/providers/consultation_provider.dart`)

**Added `is_available` to query:**

```dart
.select('''
  id,
  consultation_type,
  scheduled_time,
  consultation_status,
  doctors!inner (
    id,
    user_id,
    bmcd_registration_number,
    specialization,
    qualification,
    consultation_fee,
    availability_start,
    availability_end,
    is_available,  // ← Added this field
    bio,
    created_at,
    users!inner (
      full_name,
      email,
      profile_picture_url
    )
  )
''')
```

### 3. Doctor Repository

No changes needed - already uses `*` selector which includes `is_available`:

```dart
final response = await _supabase
    .from('doctors')
    .select('''
      *,  // This includes is_available
      users!inner (
        full_name,
        email,
        profile_picture_url
      )
    ''')
```

## 🎯 Benefits

### ✅ Single Source of Truth

- Availability logic is managed in **one place** (backend/database)
- Frontend just displays the status
- No complex calculations on the client side

### ✅ Consistent Behavior

- All clients (web, mobile, doctor side, patient side) see the same status
- No timezone confusion
- No calculation discrepancies

### ✅ Flexible Backend Logic

The backend can update `is_available` based on:

- Real-time doctor online status
- Scheduled availability hours
- Day-of-week schedules
- Special holidays/breaks
- Any other business rules

### ✅ Performance

- No complex time calculations on every UI render
- Simple boolean field access
- Faster UI updates

## 📊 UI Behavior

### When `is_available = true`

- ✅ Green indicator dot
- ✅ "Available" text
- ✅ Video call button **enabled**
- ✅ Can start instant consultation

### When `is_available = false`

- ⭕ Grey indicator dot
- ⭕ "Offline" text
- ⭕ Video call button **disabled**
- ⭕ Cannot start instant consultation

## 🔄 Backend Update Logic

The backend should update `is_available` when:

1. **Doctor logs in/out:**

   ```sql
   UPDATE doctors
   SET is_available = true, is_online = true
   WHERE id = doctor_id;
   ```

2. **Doctor goes offline:**

   ```sql
   UPDATE doctors
   SET is_online = false,
       is_available = CASE
         WHEN availability IS NOT NULL AND availability != '{}'::jsonb
         THEN true
         ELSE false
       END
   WHERE id = doctor_id;
   ```

3. **Doctor sets/updates availability schedule:**
   ```sql
   UPDATE doctors
   SET availability = new_schedule,
       is_available = true
   WHERE id = doctor_id;
   ```

## 🧪 Testing

### Test Case 1: Doctor Online

- **Setup**: Doctor logs in on doctor side
- **Backend**: Sets `is_online = true`, `is_available = true`
- **Patient Side**: Doctor shows "Available" with green dot ✅

### Test Case 2: Doctor Offline with Schedule

- **Setup**: Doctor logs out but has availability hours set
- **Backend**: Sets `is_online = false`, `is_available = true` (has schedule)
- **Patient Side**: Doctor shows "Available" with green dot ✅

### Test Case 3: Doctor Offline without Schedule

- **Setup**: Doctor logs out and has no availability hours
- **Backend**: Sets `is_online = false`, `is_available = false`
- **Patient Side**: Doctor shows "Offline" with grey dot ✅

## 📋 Migration Notes

### Old Approach (Removed)

- ❌ Calculated availability from `availability_start` and `availability_end`
- ❌ Complex time-of-day comparisons
- ❌ Timezone handling issues
- ❌ Client-side logic duplication

### New Approach (Current)

- ✅ Uses database `is_available` field
- ✅ Backend manages all logic
- ✅ Simple boolean check
- ✅ Consistent across all clients

## 🔗 Related Files

- `lib/features/consult/domain/models/doctor.dart` - **Updated** ✅
- `lib/features/home/presentation/providers/consultation_provider.dart` - **Updated** ✅
- `lib/features/consult/data/repositories/doctor_repository.dart` - No changes (uses `*`)
- `lib/features/consult/presentation/widgets/consult_widgets.dart` - Uses `isAvailableNow` getter

## 📚 Related Documentation

- `TIME_OF_DAY_FIX.md` - Previous approach (now obsolete)
- `TIMEZONE_FIX.md` - Timezone issues (resolved by backend approach)
- `VIDEO_CALL_AVAILABILITY_FIX.md` - Video call timing logic (separate concern)

## 🎉 Result

Dr. Asif and all doctors will now show as **"Available"** when:

- ✅ They are currently online (logged in on doctor side)
- ✅ **OR** they have availability schedule set

The status is managed by the backend, ensuring consistency across all parts of the application! 🚀
