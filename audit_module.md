🚨 IMPORTANT: Ignore other modules for now (Action Plan, Safeguarding, Complaints, etc.). We are laser-focused on building and getting the Audit module done right first. Do not generate or scaffold anything unrelated.

✅ Audit Module Instructions
The Audit module should include the following functionality:

1. Audit Templates
Admin can create multiple audit templates.

Each template includes:

A title (e.g., “Daily Health Check”)

Audit frequency: Can be Daily, Weekly, or Monthly

A list of questions, each with:

Question text

Maximum score for the question

2. Audit Assignment
Admin can assign a template to one or more users.

When assigned, a new audit instance is created for the selected user(s).

The frequency determines how often the audit should recur (i.e., daily, weekly, or monthly audits).

Support viewing active, overdue, or completed audits for each user.

3. Audit Execution
Assigned users can fill in the audit:

Answer each question

Input score (between 0 and the question’s max score)

Display the total score and allow notes to be attached

4. Audit Tracking & Status
Admin and users should be able to:

See the status: Pending, In Progress, Completed, Overdue

See due date based on the frequency

Filter audits by user, date, template, and status

View historical audits for trends

5. Audit Insights (Basic Analytics)
Show percentage of completion for ongoing audits

Display total average score across audits (per template/user)

Flag audits with scores below threshold (e.g., <70%)

💡 Notes

Use Supabase for DB and auth.

Email assignment notifications via Resend.com.

This is the only module to focus on right now.

