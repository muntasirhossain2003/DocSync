# Doctor Video Consultation Booking Flow - Implementation Guide

## 📋 Overview

Complete implementation of a doctor video consultation booking system following clean architecture principles with:

- Multi-step booking flow (Browse → Book → Checkout → Pay → Join Call)
- Payment options (Subscription or direct payment via bKash/Nagad/Card)
- Time window validation (join 5 mins before, auto-expire after 15 mins)
- 15-minute consultation duration
- Supabase backend integration

## 🏗️ Architecture

### Feature Structure

```
lib/features/booking/
├── domain/
│   └── models/
│       ├── consultation.dart        # Consultation model with status, payment, timing
│       ├── booking_slot.dart        # Time slot model with availability
│       └── payment_method.dart      # Payment types and results
├── data/
│   ├── repositories/
│   │   └── consultation_repository.dart  # CRUD operations for consultations
│   └── services/
│       └── payment_service.dart          # Payment processing logic
└── presentation/
    ├── pages/
    │   ├── booking_page.dart             # Main booking screen
    │   └── checkout_page.dart            # Payment checkout screen
    ├── providers/
    │   ├── booking_provider.dart         # Booking state management
    │   └── consultation_provider.dart    # Consultation actions
    └── widgets/
        ├── doctor_info_card.dart         # Doctor details display
        ├── consultation_type_selector.dart # Video/Audio/Chat selector
        ├── date_selector_widget.dart     # Calendar date picker
        └── time_slot_widget.dart         # Available time slots grid
```

## 🔄 User Flow

### 1. Browse Doctors (Consult Page)

- User sees list of available doctors
- Can filter by specialization and search
- Sees doctor availability status (online/offline)
- Taps **"Book Now"** button

### 2. Booking Page (`/booking`)

**Components:**

- Doctor info card (name, specialization, fee, photo)
- Consultation type selector (Video/Audio/Chat)
- Date selector (next 14 days)
- Time slot grid (9 AM - 8 PM, 30-min intervals)
- Optional notes field
- Booking summary
- "Proceed to Checkout" button

**Validation:**

- Must select a time slot
- Slot must be available (not in the past)
- Creates consultation record with status: `pending`

### 3. Checkout Page (`/booking/checkout`)

**Features:**

- Consultation summary (doctor, date, time, type, fee)
- Payment method selection:
  - **Use Subscription** (if active subscription exists)
  - bKash
  - Nagad
  - Credit/Debit Card
- Total amount display (Free if subscription, else consultation fee)
- "Confirm Payment" button

**Payment Processing:**

1. Validates selected payment method
2. Processes payment based on type:
   - **Subscription**: Deducts from quota, marks as paid
   - **bKash/Nagad/Card**: Processes payment (mock implementation)
3. Updates consultation status to `confirmed` and `is_paid: true`
4. Shows success dialog
5. Navigates to home page

### 4. Joining Video Call

**Access Control:**

- Can join **5 minutes before** scheduled time
- Can join up to **15 minutes after** scheduled time
- Must be paid (`is_paid: true`)
- Must have status `confirmed`

**Auto-Expiry:**

- Consultations unpaid after 15 minutes are auto-expired
- Status changes to `expired`

## 📊 Database Schema

### Consultations Table

```sql
CREATE TABLE consultations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  patient_id UUID REFERENCES users(id),
  doctor_id UUID REFERENCES doctors(id),
  doctor_name TEXT NOT NULL,
  doctor_profile_url TEXT,
  patient_name TEXT NOT NULL,
  patient_profile_url TEXT,
  consultation_type TEXT NOT NULL, -- 'video', 'audio', 'chat'
  status TEXT NOT NULL, -- 'pending', 'confirmed', 'paid', 'inProgress', 'completed', 'cancelled', 'expired'
  scheduled_time TIMESTAMP NOT NULL,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  fee DECIMAL(10, 2) NOT NULL,
  is_paid BOOLEAN DEFAULT FALSE,
  payment_method TEXT, -- 'subscription', 'bkash', 'nagad', 'card'
  notes TEXT,
  agora_channel_name TEXT,
  agora_token TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);
```

### Payments Table

```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  consultation_id UUID REFERENCES consultations(id),
  user_id UUID REFERENCES users(id),
  payment_type TEXT NOT NULL,
  transaction_id TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🎯 Key Features

### Time Window Validation

```dart
bool canJoin() {
  final now = DateTime.now();
  final startWindow = scheduledTime.subtract(const Duration(minutes: 5));
  final endWindow = scheduledTime.add(const Duration(minutes: 15));

  return now.isAfter(startWindow) &&
         now.isBefore(endWindow) &&
         isPaid &&
         status == ConsultationStatus.confirmed;
}
```

### Consultation Status Flow

```
pending → confirmed (after payment) → inProgress (call started) → completed (call ended)
                                  ↓
                              expired (15 mins after scheduled time if unpaid)
                                  ↓
                              cancelled (user cancels)
```

### Payment Methods

1. **Subscription**: Free for active subscribers, deducts from monthly quota
2. **bKash**: Mobile wallet payment (mock implementation - integrate with bKash API)
3. **Nagad**: Mobile wallet payment (mock implementation - integrate with Nagad API)
4. **Card**: Credit/Debit card (mock implementation - integrate with Stripe/SSLCommerz)

## 🔌 Integration Points

### Update Consult Widgets

The `_bookConsultation` method now navigates to the booking page:

```dart
void _bookConsultation(BuildContext context, Doctor doctor) {
  context.push('/booking', extra: doctor);
}
```

### Router Configuration

New routes added:

```dart
GoRoute(
  path: '/booking',
  builder: (context, state) {
    final doctor = state.extra as Doctor;
    return BookingPage(doctor: doctor);
  },
  routes: [
    GoRoute(
      path: 'checkout',
      builder: (context, state) {
        final consultation = state.extra as Consultation;
        return CheckoutPage(consultation: consultation);
      },
    ),
  ],
),
```

## 🎨 UI/UX Highlights

### Material 3 Theming

- Consistent use of `Theme.of(context).colorScheme`
- AppConstants for spacing and border radius
- Fluent UI System Icons
- Responsive design with proper padding

### Smooth Navigation

- Step-by-step flow with back navigation support
- Loading states during async operations
- Error handling with SnackBars
- Success confirmation dialog

### User Feedback

- Selected states for dates, time slots, payment methods
- Disabled states for unavailable slots
- Loading indicators during payment processing
- Clear error messages

## 🚀 Usage Example

```dart
// In consult page, when user taps "Book Now"
ElevatedButton(
  onPressed: () => _bookConsultation(context, doctor),
  child: const Text('Book Now'),
)

// Navigation flow:
// 1. /booking → Select date/time
// 2. /booking/checkout → Select payment & confirm
// 3. Success → Navigate to /home
// 4. User can join call from upcoming consultations widget
```

## ⚙️ Provider Usage

### Booking Providers

```dart
// Select doctor
ref.read(selectedDoctorProvider.notifier).state = doctor;

// Select date
ref.read(selectedDateProvider.notifier).state = DateTime.now();

// Select time slot
ref.watch(selectedTimeSlotProvider);

// Create booking
await ref.read(bookingProvider.notifier).createBooking(...)

// Process payment
await ref.read(paymentProvider.notifier).processPayment(...)

// Check subscription
final hasSubscription = await ref.read(hasActiveSubscriptionProvider.future);
```

## 📝 TODO: Integration Steps

### 1. Payment Gateway Integration

Currently using mock implementations. Integrate with:

- **bKash**: https://developer.bka.sh/
- **Nagad**: https://developer.nagad.com.bd/
- **SSLCommerz** or **Stripe**: For card payments

### 2. Agora Token Generation

Implement server-side token generation for Agora RTC:

```dart
Future<String> generateAgoraToken(String channelName, String userId) async {
  // Call your backend API to generate token
  // Backend should use Agora RTC Token Builder
}
```

### 3. Background Job for Expiry

Set up a Supabase Function or cron job to auto-expire consultations:

```sql
-- Run every 5 minutes
UPDATE consultations
SET status = 'expired', updated_at = NOW()
WHERE is_paid = FALSE
  AND scheduled_time < (NOW() - INTERVAL '15 minutes')
  AND status IN ('pending', 'confirmed');
```

### 4. Push Notifications

Send notifications for:

- Booking confirmation
- 15-minute reminder before consultation
- Doctor joined the call
- Consultation completed

### 5. Video Call Enhancement

Update VideoCallPage to:

- Check time window before allowing join
- Update consultation status to `inProgress` on start
- Update to `completed` on end
- Enforce 15-minute duration limit

## ✅ Benefits of This Implementation

1. **Clean Architecture**: Clear separation of concerns (domain, data, presentation)
2. **Scalable**: Easy to add new payment methods or consultation types
3. **Type-Safe**: Strong typing with enums and models
4. **Testable**: Business logic separated from UI
5. **User-Friendly**: Multi-step flow with clear feedback
6. **Maintainable**: Modular widgets and providers
7. **Consistent UI**: Material 3 theming throughout

## 🔍 Error Handling

The system handles various error scenarios:

- Network failures during booking/payment
- Invalid time slots (past times)
- Insufficient subscription quota
- Payment failures
- User not authenticated
- Database errors

All errors are displayed to users via SnackBars with appropriate messages.

## 📱 Testing Checklist

- [ ] Book consultation with subscription
- [ ] Book consultation with direct payment
- [ ] Verify time slot validation (can't select past times)
- [ ] Test time window for joining (5 mins before to 15 mins after)
- [ ] Verify auto-expiry of unpaid consultations
- [ ] Test navigation flow (back button behavior)
- [ ] Verify consultation status updates
- [ ] Test with/without active subscription
- [ ] Verify payment recording in database
- [ ] Test error scenarios (network failure, invalid data)

---

**Created**: October 2025
**Status**: Complete - Ready for integration testing
**Next Steps**: Integrate payment gateways, implement Agora token generation, set up auto-expiry background job
