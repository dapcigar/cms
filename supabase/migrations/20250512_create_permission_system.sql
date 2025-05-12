-- Create groups table
CREATE TABLE IF NOT EXISTS public.groups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Create group permissions table
CREATE TABLE IF NOT EXISTS public.group_permissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    permission TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    UNIQUE(group_id, permission)
);

-- Create user groups table (for assigning users to groups)
CREATE TABLE IF NOT EXISTS public.user_groups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, group_id)
);

-- Create user permissions table (for individual overrides)
CREATE TABLE IF NOT EXISTS public.user_permissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    permission TEXT NOT NULL,
    granted BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, permission)
);

-- Enable RLS on all tables
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

-- Create policies for groups table
CREATE POLICY "Enable read access for authenticated users" ON public.groups
    FOR SELECT
    TO authenticated
    USING (true);

-- Create policies for group_permissions table
CREATE POLICY "Enable read access for authenticated users" ON public.group_permissions
    FOR SELECT
    TO authenticated
    USING (true);

-- Create policies for user_groups table
CREATE POLICY "Enable read access for authenticated users" ON public.user_groups
    FOR SELECT
    TO authenticated
    USING (true);

-- Create policies for user_permissions table
CREATE POLICY "Enable read access for authenticated users" ON public.user_permissions
    FOR SELECT
    TO authenticated
    USING (true);

-- Add trigger for updated_at on groups
CREATE TRIGGER handle_groups_updated_at
    BEFORE UPDATE ON public.groups
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Add trigger for updated_at on group_permissions
CREATE TRIGGER handle_group_permissions_updated_at
    BEFORE UPDATE ON public.group_permissions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Add trigger for updated_at on user_groups
CREATE TRIGGER handle_user_groups_updated_at
    BEFORE UPDATE ON public.user_groups
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Add trigger for updated_at on user_permissions
CREATE TRIGGER handle_user_permissions_updated_at
    BEFORE UPDATE ON public.user_permissions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Insert default groups
INSERT INTO public.groups (name, description)
VALUES 
('Administrators', 'Full system access with all permissions'),
('Auditors', 'Users who can manage audits'),
('Viewers', 'Users with read-only access');

-- Insert default permissions for Administrators group
INSERT INTO public.group_permissions (group_id, permission)
SELECT 
    id,
    unnest(ARRAY[
        'can_view_audits',
        'can_edit_audits',
        'can_assign_audits',
        'can_close_audits',
        'can_create_audits',
        'can_delete_audits'
    ])
FROM public.groups
WHERE name = 'Administrators';

-- Insert default permissions for Auditors group
INSERT INTO public.group_permissions (group_id, permission)
SELECT 
    id,
    unnest(ARRAY[
        'can_view_audits',
        'can_edit_audits',
        'can_assign_audits',
        'can_close_audits',
        'can_create_audits'
    ])
FROM public.groups
WHERE name = 'Auditors';

-- Insert default permissions for Viewers group
INSERT INTO public.group_permissions (group_id, permission)
SELECT 
    id,
    unnest(ARRAY[
        'can_view_audits'
    ])
FROM public.groups
WHERE name = 'Viewers';

-- Create function to check if a user has a specific permission
CREATE OR REPLACE FUNCTION public.user_has_permission(user_uuid UUID, required_permission TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    has_permission BOOLEAN;
BEGIN
    -- First check if there's a user-specific override
    SELECT granted INTO has_permission
    FROM public.user_permissions
    WHERE user_id = user_uuid AND permission = required_permission;
    
    -- If there's a user-specific override, return that value
    IF has_permission IS NOT NULL THEN
        RETURN has_permission;
    END IF;
    
    -- Otherwise, check if the user has the permission through any of their groups
    SELECT EXISTS (
        SELECT 1
        FROM public.user_groups ug
        JOIN public.group_permissions gp ON ug.group_id = gp.group_id
        WHERE ug.user_id = user_uuid AND gp.permission = required_permission
    ) INTO has_permission;
    
    RETURN COALESCE(has_permission, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update audit policies to use the permission system
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.audits;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.audits;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.audits;

-- Create new policies based on permissions
CREATE POLICY "Enable read access based on permission" ON public.audits
    FOR SELECT
    TO authenticated
    USING (public.user_has_permission(auth.uid(), 'can_view_audits'));

CREATE POLICY "Enable insert access based on permission" ON public.audits
    FOR INSERT
    TO authenticated
    WITH CHECK (public.user_has_permission(auth.uid(), 'can_create_audits'));

CREATE POLICY "Enable update access based on permission" ON public.audits
    FOR UPDATE
    TO authenticated
    USING (public.user_has_permission(auth.uid(), 'can_edit_audits'))
    WITH CHECK (public.user_has_permission(auth.uid(), 'can_edit_audits'));

CREATE POLICY "Enable delete access based on permission" ON public.audits
    FOR DELETE
    TO authenticated
    USING (public.user_has_permission(auth.uid(), 'can_delete_audits'));
