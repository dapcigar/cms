🔐 User Permission System Setup for Care Management System (Audit Module)

Hey Windsurf! Please follow these instructions carefully — no freestyling.

1. Group-Based Permission
Create a Groups table.

Each group has a predefined set of permissions (e.g., can_view_audits, can_edit_audits, can_assign_audits, can_close_audits).

When a user is assigned to a group, they inherit these permissions.

2. Individual User Overrides
Users can have individual permission overrides.

A UserPermissions table should exist that overrides the group setting per user if set.

If a permission is not overridden at the user level, fallback to group-level permissions.

3. Permission Enforcement
Every action (e.g., view, create, assign, edit, delete audit) should check:

If the user has that permission individually.

If not individually set, then check the user’s group permissions.

Use Supabase Row-Level Security (RLS) to restrict data access based on permissions.

4. Admin Role
Admins bypass all permission checks.

Admins can:

Create users

Assign them to groups

Grant or override permissions individually

Trigger invite emails using Resend.com

5. Frontend UI Behavior
Pages and UI components should check if a user has permission before displaying options/buttons (e.g., “Assign Audit” button should only appear if can_assign_audits is true).

A permissions hook or utility should expose an easy way to check access in React (e.g., usePermission("can_edit_audits")).

6. Password Setup Flow
On user creation:

Generate a secure password setup link.

Send this via Resend.com email.

On first login, users set their password and land on their dashboard.

