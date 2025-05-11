-- Rename existing safeguarding table if it exists
ALTER TABLE IF EXISTS public.safeguarding RENAME TO safeguarding_cases;

-- Create safeguarding_cases table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.safeguarding_cases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open',
  priority TEXT DEFAULT 'medium',
  assigned_users UUID[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create update trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER safeguarding_cases_updated
BEFORE UPDATE ON public.safeguarding_cases
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Grant permissions
ALTER TABLE public.safeguarding_cases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.safeguarding_cases
FOR SELECT USING (true);
