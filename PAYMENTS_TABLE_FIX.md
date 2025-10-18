# Payments Table Fix - Complete Guide

## Problem

The booking flow was trying to insert payment records into `public.payments` table, but only `public.subscription_payments` existed in the database.

**Error Message:**

```
Exception: Failed to record payment:
PostgrestException(message: Could not find the table 'public.payments' in the schema cache,
code: PGRST205, details: Not Found, hint: Perhaps you mean the table 'public.subscription_payments')
```

---

## Solution

### 1. Create New `payments` Table

Run this SQL in your Supabase SQL Editor:

```sql
-- Create the payments table for consultation payments
CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  consultation_id uuid,
  user_id uuid NOT NULL,
  payment_type character varying NOT NULL CHECK (
    payment_type::text = ANY (
      ARRAY[
        'subscription'::character varying,
        'bkash'::character varying,
        'nagad'::character varying,
        'card'::character varying,
        'cash'::character varying
      ]::text[]
    )
  ),
  transaction_id character varying NOT NULL,
  amount numeric NOT NULL,
  status character varying NOT NULL DEFAULT 'completed' CHECK (
    status::text = ANY (
      ARRAY[
        'pending'::character varying,
        'completed'::character varying,
        'failed'::character varying,
        'refunded'::character varying
      ]::text[]
    )
  ),
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT payments_pkey PRIMARY KEY (id),
  CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE,
  CONSTRAINT payments_consultation_id_fkey FOREIGN KEY (consultation_id) REFERENCES public.consultations(id) ON DELETE SET NULL
);

-- Create indexes for faster queries
CREATE INDEX idx_payments_user_id ON public.payments(user_id);
CREATE INDEX idx_payments_consultation_id ON public.payments(consultation_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_payments_created_at ON public.payments(created_at DESC);
```

---

## Table Structure Comparison

### NEW: `payments` Table (For Consultations)

| Column          | Type      | Purpose                                          |
| --------------- | --------- | ------------------------------------------------ |
| id              | uuid      | Primary key                                      |
| consultation_id | uuid      | Links to consultations table                     |
| user_id         | uuid      | Who made the payment                             |
| payment_type    | varchar   | 'subscription', 'bkash', 'nagad', 'card', 'cash' |
| transaction_id  | varchar   | Unique transaction ID                            |
| amount          | numeric   | Payment amount                                   |
| status          | varchar   | 'pending', 'completed', 'failed', 'refunded'     |
| created_at      | timestamp | When payment was created                         |
| updated_at      | timestamp | When payment was last updated                    |

### EXISTING: `subscription_payments` Table (Keep This!)

| Column          | Type      | Purpose                                       |
| --------------- | --------- | --------------------------------------------- |
| id              | uuid      | Primary key                                   |
| user_id         | uuid      | Who purchased subscription                    |
| subscription_id | uuid      | Links to subscriptions table                  |
| amount          | numeric   | Subscription cost                             |
| payment_method  | varchar   | 'bKash', 'Nagad', 'credit_card', 'debit_card' |
| payment_status  | varchar   | 'pending', 'completed', 'failed'              |
| payment_number  | numeric   | Payment number                                |
| created_at      | timestamp | When payment was created                      |

**Key Difference:**

- `payments` = For individual consultation payments
- `subscription_payments` = For subscription plan purchases

---

## Code Verification

The Flutter code in `payment_service.dart` is already correct and matches the new schema:

```dart
// Record payment in database
Future<void> recordPayment({
  required String consultationId,
  required String userId,
  required PaymentType paymentType,
  required String transactionId,
  required double amount,
}) async {
  try {
    await _supabase.from('payments').insert({
      'consultation_id': consultationId,
      'user_id': userId,
      'payment_type': paymentType.name,  // ✅ Correct field name
      'transaction_id': transactionId,
      'amount': amount,
      'status': 'completed',
      'created_at': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    throw Exception('Failed to record payment: $e');
  }
}
```

✅ **No code changes needed!** The Flutter code already expects the correct schema.

---

## Testing Steps

After running the SQL migration:

1. **Go to Supabase Dashboard** → SQL Editor
2. **Paste and run** the CREATE TABLE command above
3. **Verify table creation:**
   ```sql
   SELECT * FROM information_schema.tables
   WHERE table_name = 'payments';
   ```
4. **Test in your app:**
   - Book a consultation
   - Select any payment method
   - Click "Confirm Payment"
   - Should succeed and redirect to home

---

## Expected Behavior After Fix

1. ✅ User books consultation
2. ✅ Selects payment method (bKash, Nagad, Card, or Subscription)
3. ✅ Clicks "Confirm Payment"
4. ✅ Payment record is saved to `payments` table
5. ✅ Consultation status updated
6. ✅ Success dialog appears
7. ✅ User redirected to home page

---

## Troubleshooting

### If you still get the error:

1. **Check RLS (Row Level Security):**

   ```sql
   -- Disable RLS for testing (enable it later with proper policies)
   ALTER TABLE public.payments DISABLE ROW LEVEL SECURITY;
   ```

2. **Check table exists:**

   ```sql
   SELECT table_name FROM information_schema.tables
   WHERE table_schema = 'public' AND table_name = 'payments';
   ```

3. **Grant permissions:**
   ```sql
   GRANT ALL ON public.payments TO authenticated;
   GRANT ALL ON public.payments TO service_role;
   ```

---

## Enable RLS (Recommended for Production)

After testing, enable Row Level Security:

```sql
-- Enable RLS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own payments
CREATE POLICY "Users can view own payments"
  ON public.payments
  FOR SELECT
  TO authenticated
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Policy: Users can create payments
CREATE POLICY "Users can create payments"
  ON public.payments
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Policy: Service role has full access
CREATE POLICY "Service role full access"
  ON public.payments
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
```

---

## Summary

- ✅ Created new `payments` table for consultation payments
- ✅ Kept existing `subscription_payments` table for subscription purchases
- ✅ No Flutter code changes needed
- ✅ Run the SQL migration in Supabase
- ✅ Test the booking flow

The issue is purely on the database side. Once you create the `payments` table, everything will work! 🚀
