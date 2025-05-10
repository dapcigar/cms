-- Fix for the missing assigned_users column in the incidents table
-- Run this in your Supabase SQL Editor

-- Check if the column exists first
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'incidents'
        AND column_name = 'assigned_users'
    ) THEN
        -- Add the column if it doesn't exist
        ALTER TABLE public.incidents ADD COLUMN assigned_users UUID[] DEFAULT '{}';
    END IF;
END
$$;
