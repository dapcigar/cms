-- Migration: Update handle_new_user function to use text for role
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
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
END;
$$ LANGUAGE plpgsql;
