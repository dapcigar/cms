Product Requirements Document (PRD)

Product Name: Care Management System

Prepared For: Windsurf AI Development Platform

1. Purpose

To build a web and mobile-friendly Care Management System (CMS) that empowers healthcare providers to manage audits, action plans, safeguarding issues, incidents & accidents, complaints & compliments, surveys, and system analytics. The app will feature robust role and permission-based access, real-time notifications, and seamless user experiences powered by Supabase and hosted on Vercel.

2. Scope

This app supports users (Admin, Staff, Safeguarding Officer, etc.) in performing and managing key compliance and operational tasks. It will include real-time updates, vibrant UI, email notifications, secure user management, and scalable architecture.

3. Features

3.1 User Management

Admin can create users.

Assign users to groups (roles) with preset permissions.

Override group permissions with individual permissions.

Send email via Resend.com for user onboarding.

Users set up their password via secure invite link.

3.2 Permissions & Access Control

Role-based group permissions.

Individual user overrides.

Supabase Row-Level Security (RLS) policies.

Fine-grained access control to specific modules/actions.

3.3 Audits

Users can create and manage audits.

Assign audits to other users.

Track audit status (open, closed).

Attach action plans to audits.

View only accessible audits.

3.4 Action Plans

Create standalone or related action plans.

Can link to audits, complaints, safeguarding, etc.

Assign to multiple users.

Track progress and due dates.

3.5 Safeguarding

Log safeguarding concerns.

Assign responsible parties.

Confidentiality and access restrictions.

Link to relevant action plans.

3.6 Surveys

Create and assign surveys to users.

Collect structured responses.

Generate reports from survey data.

Use for audits, feedback, performance review.

3.7 Incidents & Accidents

Log incidents or accidents.

Track resolution progress.

Assign to staff.

Can trigger related action plans.

3.8 Complaints & Compliments

Users log complaints or compliments.

Admin can respond and manage status.

Connect with action plans if needed.

3.9 Analytics Module

Visual dashboard for audits, incidents, action plans, and user activities.

Charts and metrics for data trends.

Custom queries for performance tracking.

3.10 Notifications

Send notifications via Resend.com:

New assignments.

Survey invitations.

Password setup links.

Audit updates, incident resolutions.

4. Technical Architecture

Frontend

Framework: ReactJS

Design System: Mobile-first, vibrant, clean UI

Hosting: Vercel

Backend

Platform: Supabase

Authentication: Supabase Auth

Database: PostgreSQL (via Supabase)

Real-time: Supabase Live Subscriptions

Storage: Supabase Buckets

RLS: Supabase Row Level Security

Notifications

Service: Resend.com

Use for: Account setup, alerts, updates

5. User Roles

Admin: Full access, manage users, permissions.

Staff: Access based on group/individual permissions.

Safeguarding Officer: Specific access to safeguarding logs.

Viewer: Read-only access where allowed.

6. User Stories

Refer to user stories document (linked separately) which outlines all relevant scenarios per feature/module.

7. Deliverables

Supabase project with tables and RLS set up.

ReactJS frontend deployed on Vercel.

Resend.com integration.

Email onboarding flow.

Role & permission UI.

Functional modules for:

Audits

Action Plans

Safeguarding

Surveys

Incidents

Complaints

Analytics Dashboard

Responsive UI with modern design.

Real-time syncing via Supabase.

8. Success Criteria

100% mobile responsiveness.

Scalable backend with no vendor lock-in.

Admins can onboard users easily.

Role-based access works as intended.

All modules can CRUD and link related records.

Real-time data update visibility.

Email notifications triggered appropriately.

9. Out of Scope (for MVP)

Mobile app (native)

Multilingual support

External integrations beyond Resend

10. Timeline

Week 1: Data models, auth, and roles
Week 2: Audit & Action Plan modules
Week 3: Safeguarding, Incident, Complaint
Week 4: Surveys, Analytics, UI polish
Week 5: QA, Deployment

11. Notes

Design vibe: Clean, energetic, vibrant

Real-time feedback essential

Expandable modules and microservice-ready for future phases

11.1 Layout

Navigation: Left sidebar (collapsible) for modules; top bar for user settings & notifications

Main View: Grid/card layouts for modules like audits, incidents

Detail Views: Tabbed interfaces for actions, updates, and logs

Forms: Multi-step forms for onboarding, surveys, and logs

Analytics: Dashboard layout with cards, charts, and filters

11.2 Color Scheme

Primary: #0070F3 (Vibrant Blue)

Accent: #FF7A59 (Coral Orange)

Background: #F9FAFB (Light Gray)

Text: #1F2937 (Slate Gray)

Success: #10B981 (Emerald)

Error: #EF4444 (Red)

Info: #3B82F6 (Blue)

The design system will follow a friendly but professional aesthetic with clean typography (Inter or Open Sans), large touch targets, and smooth transitions.

