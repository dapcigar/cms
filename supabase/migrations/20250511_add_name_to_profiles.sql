-- Add name column to profiles table for user display names
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS name TEXT;
