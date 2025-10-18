-- ============================================
-- Payments Table Migration
-- ============================================
-- This creates a general payments table for all consultation payments
-- Separate from subscription_payments which is for subscription purchases

-- Drop the table if it exists (be careful in production!)
DROP TABLE IF EXISTS public.payments CASCADE;

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

-- Add comment to table
COMMENT ON TABLE public.payments IS 'Stores payment records for consultations (separate from subscription_payments)';

-- Verify the table was created
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'payments'
ORDER BY ordinal_position;
