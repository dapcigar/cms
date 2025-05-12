-- Create audit_templates table
CREATE TABLE IF NOT EXISTS audit_templates (
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
