-- ============================================
-- QUICK FIX: Run this in Supabase SQL Editor
-- ============================================

-- Create the payments table
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

-- Create indexes
CREATE INDEX idx_payments_user_id ON public.payments(user_id);
CREATE INDEX idx_payments_consultation_id ON public.payments(consultation_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_payments_created_at ON public.payments(created_at DESC);

-- Disable RLS for now (enable later with proper policies)
ALTER TABLE public.payments DISABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT ALL ON public.payments TO authenticated;
GRANT ALL ON public.payments TO service_role;
