-- View for audit completion rates by template
CREATE OR REPLACE VIEW audit_completion_rates AS
SELECT 
  t.id AS template_id,
  t.title AS template_title,
  COUNT(a.id) FILTER (WHERE a.status = 'completed') AS completed_count,
  COUNT(a.id) AS total_count,
  ROUND((COUNT(a.id) FILTER (WHERE a.status = 'completed') * 100.0 / NULLIF(COUNT(a.id), 0)), 2) AS completion_rate
FROM 
  audit_templates t
LEFT JOIN 
  audit_assignments a ON t.id = a.template_id
GROUP BY 
  t.id, t.title;

-- View for audit score distribution
CREATE OR REPLACE VIEW audit_score_distribution AS
WITH score_ranges AS (
  SELECT 
    CASE 
      WHEN (r.score * 100.0 / q.max_score) < 50 THEN '0-49%'
      WHEN (r.score * 100.0 / q.max_score) < 70 THEN '50-69%'
      WHEN (r.score * 100.0 / q.max_score) < 85 THEN '70-84%'
      ELSE '85-100%'
    END AS score_range
  FROM 
    audit_responses r
  JOIN 
    audit_questions q ON r.question_id = q.id
)
SELECT 
  score_range,
  COUNT(*) AS count
FROM 
  score_ranges
GROUP BY 
  score_range
ORDER BY 
  score_range;
