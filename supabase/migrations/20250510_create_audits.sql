-- Create audit_templates table
CREATE TABLE IF NOT EXISTS audit_templates (
  description text,
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Create audit_questions table
CREATE TABLE IF NOT EXISTS audit_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES audit_templates(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  max_score INTEGER NOT NULL CHECK (max_score > 0),
  question_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create audit_assignments table
CREATE TABLE IF NOT EXISTS audit_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES audit_templates(id) ON DELETE CASCADE,
  assigned_to UUID NOT NULL REFERENCES auth.users(id),
  assigned_by UUID NOT NULL REFERENCES auth.users(id),
  due_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'overdue')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create audit_responses table
CREATE TABLE IF NOT EXISTS audit_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES audit_assignments(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES audit_questions(id) ON DELETE CASCADE,
  score INTEGER NOT NULL CHECK (score >= 0),
  notes TEXT,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_audit_assignments_assigned_to ON audit_assignments(assigned_to);
CREATE INDEX IF NOT EXISTS idx_audit_assignments_template_id ON audit_assignments(template_id);
CREATE INDEX IF NOT EXISTS idx_audit_assignments_status ON audit_assignments(status);
CREATE INDEX IF NOT EXISTS idx_audit_responses_assignment_id ON audit_responses(assignment_id);

-- Add foreign key for assigned_to referencing profiles
ALTER TABLE audit_assignments
ADD CONSTRAINT audit_assignments_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES profiles(id);

-- Create audits table (for completed audit records)
CREATE TABLE IF NOT EXISTS audits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES audit_templates(id) ON DELETE CASCADE,
  assigned_to UUID NOT NULL REFERENCES profiles(id),
  status TEXT CHECK (status IN ('pending','in-progress','completed')) DEFAULT 'pending',
  completed_at TIMESTAMPTZ,
  scores JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add indexes for audits table
CREATE INDEX IF NOT EXISTS idx_audits_template ON audits(template_id);
CREATE INDEX IF NOT EXISTS idx_audits_assigned_to ON audits(assigned_to);

-- Enable RLS on audits table
ALTER TABLE audits ENABLE ROW LEVEL SECURITY;

-- Create policies for audits table
CREATE POLICY "Authenticated users can view audits"
  ON audits FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert audits"
  ON audits FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own audits"
  ON audits FOR UPDATE
  TO authenticated
  USING (assigned_to = auth.uid());