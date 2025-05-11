-- Add assigned_users column to action_plans table
ALTER TABLE public.action_plans
ADD COLUMN IF NOT EXISTS assigned_users UUID[] DEFAULT '{}';
