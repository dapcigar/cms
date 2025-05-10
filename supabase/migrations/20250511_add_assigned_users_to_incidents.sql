-- Add assigned_users column to incidents table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'incidents'
        AND column_name = 'assigned_users'
    ) THEN
        ALTER TABLE public.incidents ADD COLUMN assigned_users UUID[] DEFAULT '{}';
    END IF;
END
$$;
