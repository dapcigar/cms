-- Fix user creation issues by addressing RLS policies and function security

-- 1. Add RLS policy to allow inserts for auth functions
CREATE POLICY "Allow inserts for authenticated users"
ON public.profiles
FOR INSERT
TO authenticated, service_role, supabase_auth_admin
WITH CHECK (true);

-- 2. Update the handle_new_user function to use SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER -- This makes the function run with the privileges of the owner
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'role',
            'staff'
        )
    );
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error in handle_new_user: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
