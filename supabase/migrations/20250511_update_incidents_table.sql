-- Migration to update the incidents table with missing columns
-- Add updated_at column with trigger for automatic updates
ALTER TABLE public.incidents 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Create function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_incidents_updated_at ON public.incidents;
CREATE TRIGGER update_incidents_updated_at
BEFORE UPDATE ON public.incidents
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Add columns for related items
ALTER TABLE public.incidents 
ADD COLUMN IF NOT EXISTS action_plan_ids UUID[] DEFAULT '{}';

ALTER TABLE public.incidents 
ADD COLUMN IF NOT EXISTS audit_ids UUID[] DEFAULT '{}';

ALTER TABLE public.incidents 
ADD COLUMN IF NOT EXISTS safeguarding_case_ids UUID[] DEFAULT '{}';
