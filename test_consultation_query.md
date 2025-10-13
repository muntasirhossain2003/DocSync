# Consultation Query Test

## Issue Analysis

The consultation query filters by:

1. `patient_id` = current user's ID
2. `consultation_status` = 'scheduled'
3. `scheduled_time` >= NOW()

## Possible Issues

### 1. Scheduled Time in the Past

If your consultation's `scheduled_time` is in the past, it will be filtered out by:

```dart
.gte('scheduled_time', DateTime.now().toIso8601String())
```

**Check**: Is the consultation scheduled for a future date/time?

### 2. Patient ID Mismatch

The query looks up the user ID from the `users` table using `auth_id`:

```dart
.from('users').select('id').eq('auth_id', authUserId).single()
```

**Check**: Does the consultation's `patient_id` match the ID returned from this lookup?

### 3. Consultation Status

The query filters for status = 'scheduled' (case-sensitive):

```dart
.eq('consultation_status', 'scheduled')
```

**Check**: Is the consultation_status exactly 'scheduled' (not 'Scheduled', 'pending', etc.)?

### 4. Doctor/User Relationship

The query uses `!inner` JOINs which means it will ONLY return consultations where:

- The doctor record exists
- The doctor's user record exists

**Check**: Does the consultation have a valid doctor_id that links to a doctor with a valid user_id?

## How to Debug

### Option 1: Check Database Directly

Run this query in Supabase SQL Editor:

```sql
SELECT
  c.id,
  c.patient_id,
  c.doctor_id,
  c.consultation_type,
  c.scheduled_time,
  c.consultation_status,
  c.scheduled_time >= NOW() as is_future,
  d.id as doctor_exists,
  u.id as doctor_user_exists
FROM consultations c
LEFT JOIN doctors d ON c.doctor_id = d.id
LEFT JOIN users u ON d.user_id = u.id
WHERE c.consultation_status = 'scheduled';
```

### Option 2: Temporarily Remove Filters

Modify the provider to test without time filter:

```dart
final response = await supabase
    .from('consultations')
    .select('''...''')
    .eq('patient_id', userId)
    .eq('consultation_status', 'scheduled')
    // .gte('scheduled_time', DateTime.now().toIso8601String()) // COMMENTED OUT FOR TESTING
    .order('scheduled_time', ascending: true)
    .limit(5);
```

### Option 3: Check Auth User ID

Print the auth user ID and manually verify in the database:

```dart
print('Auth ID: ${supabase.auth.currentUser?.id}');
```

Then check in Supabase:

```sql
SELECT id, auth_id, full_name, email
FROM users
WHERE auth_id = 'YOUR_AUTH_ID_HERE';
```

## Common Solutions

### If scheduled_time is in the past:

Update the consultation to a future date:

```sql
UPDATE consultations
SET scheduled_time = '2025-10-15 10:00:00'
WHERE id = 'YOUR_CONSULTATION_ID';
```

### If patient_id doesn't match:

Find the correct user ID and update:

```sql
-- Find your user ID
SELECT id FROM users WHERE email = 'your_email@example.com';

-- Update the consultation
UPDATE consultations
SET patient_id = 'YOUR_CORRECT_USER_ID'
WHERE id = 'YOUR_CONSULTATION_ID';
```

### If doctor relationship is broken:

Verify and fix doctor links:

```sql
-- Check if doctor and user exist
SELECT d.id, d.user_id, u.full_name
FROM doctors d
LEFT JOIN users u ON d.user_id = u.id
WHERE d.id = 'YOUR_DOCTOR_ID';
```
