# Booking Flow Schema Fix & Subscription Discount Integration

## Overview

Fixed the booking flow to match the actual Supabase database schema and integrated subscription plan discounts into the checkout process.

---

## 1. Database Schema Alignment

### Issues Fixed

1. **Column Name Mismatch**: The code was using `status` but the database has `consultation_status`
2. **Missing Fields**: The code tried to insert `doctor_name` and `patient_name` which don't exist in the `consultations` table
3. **Status Mapping**: Database uses different status values than the app (e.g., 'scheduled' vs 'pending')

### Changes Made

#### consultation_repository.dart

- Updated all queries to use `consultation_status` instead of `status`
- Removed direct `doctor_name` and `patient_name` insertions
- Added JOIN queries to fetch doctor and patient names from the `users` table via foreign keys
- Created `_transformResponse()` helper to add name fields to response
- Created `_mapStatusToDb()` to convert app status to database status values

**Status Mapping:**
| App Status | Database Status |
|------------|----------------|
| pending | scheduled |
| confirmed | scheduled |
| paid | scheduled |
| inProgress | in_progress |
| completed | completed |
| cancelled | canceled |
| expired | canceled |

#### consultation.dart

- Updated `fromJson()` to read `consultation_status` field
- Added `_mapDbStatusToApp()` static method to convert database status to app status
- Removed reliance on `start_time`, `end_time`, and `notes` fields that don't exist in DB
- Set `isPaid` to `true` for all scheduled consultations (as per business logic)

#### booking_provider.dart

- Removed unnecessary parameters from `createConsultation()` call
- Simplified to only pass required fields: `patientId`, `doctorId`, `type`, `scheduledTime`, `fee`, `notes`

---

## 2. Subscription Discount Integration

### Feature Overview

Users with active subscription plans now receive a percentage discount on consultation fees based on their plan's `rate` field.

### Database Schema Used

```sql
subscription_plans:
  - rate: numeric (discount percentage, e.g., 20 means 20% off)
  - name: text (plan name)

subscriptions:
  - user_id: uuid
  - plan_id: uuid (FK to subscription_plans)
  - status: varchar ('active', 'expired', 'pending')
  - end_at: timestamp
```

### Changes Made

#### payment_service.dart

**New Methods Added:**

1. `calculateDiscountedFee()` - Calculates discounted consultation fee

   ```dart
   Future<Map<String, dynamic>> calculateDiscountedFee({
     required String userId,
     required double originalFee,
   })
   ```

   **Returns:**

   ```dart
   {
     'originalFee': 500.0,
     'discountPercentage': 20,
     'discountAmount': 100.0,
     'discountedFee': 400.0,
     'hasSubscription': true,
     'planName': 'Premium Plan'
   }
   ```

2. Fixed `getSubscriptionDetails()` to use correct field name `end_at` instead of `end_date`

#### booking_provider.dart

**New Providers Added:**

1. `discountedFeeProvider` - FutureProvider.family that calculates discount for a given fee
   ```dart
   final discountedFeeProvider = FutureProvider.family<Map<String, dynamic>, double>((ref, originalFee) async { ... })
   ```

**Updated Methods:**

- `PaymentNotifier.processPayment()` - Now accepts `finalAmount` parameter to use discounted fee

#### checkout_page.dart

**New UI Components:**

1. **Payment Summary Section** - Shows discount breakdown when applicable:

   ```
   Consultation Fee: ৳500 (strikethrough)
   [Premium Plan Discount (20% OFF)]: -৳100
   --------------------------------
   Total Amount: ৳400
   You saved ৳100!
   ```

2. **Visual Elements:**
   - Green badge showing discount percentage and amount
   - Strikethrough on original fee
   - Green colored final amount when discount applied
   - Savings message below total

**Implementation:**

- Created `_buildPaymentSummary()` widget method
- Uses `discountedFeeProvider` to fetch discount info
- Shows loading state while calculating
- Falls back to original fee if discount calculation fails
- Updates `_processPayment()` to fetch and use discounted amount

---

## 3. How It Works (User Flow)

### For Users WITH Subscription:

1. User selects consultation → Goes to checkout
2. System checks user's active subscription plan
3. If plan exists, fetches `rate` percentage from `subscription_plans`
4. Calculates discount: `discountedFee = originalFee - (originalFee * rate / 100)`
5. UI displays:
   - Original fee (strikethrough)
   - Discount badge with percentage
   - Final discounted amount in green
   - "You saved ₹X!" message
6. Payment processes with the **discounted amount**

### For Users WITHOUT Subscription:

1. User selects consultation → Goes to checkout
2. System checks for subscription (none found)
3. UI displays only the original fee
4. Payment processes with the **full original amount**

---

## 4. Key Benefits

✅ **Schema Compliance**: All database operations now match actual Supabase schema
✅ **Proper Data Fetching**: Doctor/patient names fetched via JOIN instead of direct storage
✅ **Status Synchronization**: App and DB status values properly mapped
✅ **Subscription Value**: Users see clear value from their subscription plan
✅ **Transparent Pricing**: Discount breakdown shown clearly in UI
✅ **Flexible Discounts**: Discount percentage controlled via subscription plan `rate` field

---

## 5. Testing Checklist

### Database Schema

- [ ] Consultation creation works without errors
- [ ] Doctor and patient names display correctly in checkout
- [ ] Status updates reflect correctly in database
- [ ] Agora channel details save properly

### Subscription Discount

- [ ] User with active subscription sees discount
- [ ] Correct percentage from plan's `rate` field applied
- [ ] User without subscription sees full price
- [ ] Expired subscription doesn't apply discount
- [ ] Discount calculation handles edge cases (0%, 100%, etc.)
- [ ] Payment records save with discounted amount

### UI/UX

- [ ] Discount badge displays correctly
- [ ] Original fee shows strikethrough
- [ ] Green color indicates savings
- [ ] Loading state shows while calculating
- [ ] Error state falls back gracefully
- [ ] "You saved" message shows correct amount

---

## 6. Future Enhancements

1. **Tiered Discounts**: Different rates based on plan tier
2. **Usage Tracking**: Track how many discounted consultations used
3. **Discount Analytics**: Show total savings to user in profile
4. **Promotional Codes**: Add one-time discount codes on top of subscription
5. **Referral Discounts**: Additional discounts for referring new users

---

## 7. Database Migration Notes

**No migration required!** All changes are code-side only and work with existing schema.

However, ensure:

- `subscription_plans.rate` field contains valid percentage values (0-100)
- `subscriptions.end_at` field is properly set (not `end_date`)
- Active subscriptions have `status = 'active'`

---

## 8. Related Files Changed

### Core Changes

- `lib/features/booking/data/repositories/consultation_repository.dart`
- `lib/features/booking/domain/models/consultation.dart`
- `lib/features/booking/data/services/payment_service.dart`
- `lib/features/booking/presentation/providers/booking_provider.dart`
- `lib/features/booking/presentation/pages/checkout_page.dart`

### Dependencies

- Uses existing `subscription_plans` table
- Uses existing `subscriptions` table
- No new database tables required

---

## Contact & Support

For questions about this implementation, refer to:

- Database schema: See SQL comments in codebase
- Supabase queries: Check `consultation_repository.dart`
- Discount logic: Review `payment_service.dart`
- UI components: Examine `checkout_page.dart`
