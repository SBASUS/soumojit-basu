# Supabase + Next.js setup

## 1. Create Supabase project
Create a project at https://supabase.com/dashboard. Open SQL Editor and run `supabase/schema.sql` from this repository. The schema creates the PostgreSQL `projects` table and row-level security policies.

## 2. Create your owner login
In Supabase Dashboard → Authentication → Users, add a user with your email and a strong password. Then open SQL Editor and run this statement, replacing the email with your own:

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
where email = 'YOUR_EMAIL@example.com';
```

Check that exactly one user was updated. Never grant the admin role from a public form or client-side JavaScript. Sign out and back in after changing the role.

## 3. Configure environment variables
Use the project URL and publishable/anon key from Supabase Project Settings → API. For local development create `.env.local` in the repository root (never commit it):

```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY
```

Do not use a service-role/secret key in the app. The publishable key is only safe for client use because database row-level security is enabled.

## 4. Run locally
Install Node.js 20.9+ and run:

```bash
npm install
npm run dev
```

Open http://localhost:3000.

## 5. Deploy to Vercel
Import https://github.com/SBASUS/soumojit-basu into https://vercel.com/new. Select Next.js if asked. Add both environment variables above to Production, Preview, and Development, then deploy. GitHub Pages cannot run this Next.js server app; Vercel becomes the live host for the database-backed app. The previous static site files remain in the repository but the Next.js app uses the `app/` directory.

## 6. Admin functionality
- Public homepage reads published projects from Supabase.
- `/login` provides email/password sign-in.
- `/admin` is restricted to the authenticated user with `app_metadata.role = admin`.
- Create, edit, publish/unpublish, and delete operations run through server actions and PostgreSQL RLS.
- Admin can read unpublished drafts; public visitors cannot.

## Security checklist
- Use a unique, strong admin password.
- Never expose the Supabase service-role key or commit `.env.local`.
- Keep the admin role in trusted `app_metadata`, not user-editable `user_metadata`.
- Use RLS policies from `schema.sql`.
