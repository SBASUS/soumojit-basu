# Portfolio database setup (Supabase)

The portfolio is currently a static GitHub Pages site. GitHub Pages cannot run a server-side database itself, so this project uses **Supabase (managed PostgreSQL + authentication)** as the recommended database service. A framework migration to **Next.js** is a separate hosting change; Next.js server routes need a host such as Vercel, not GitHub Pages.

## 1. Create the database
1. Create a project at https://supabase.com/.
2. Open **SQL Editor** in the Supabase dashboard.
3. Run `supabase/schema.sql`.
4. In Authentication, enable email/password sign-in and create your admin user.

## 2. Secure admin access
The SQL policies allow everyone to read published projects, but only an authenticated user whose JWT has `app_metadata.role = "admin"` can create, update, or delete rows.
Set that role through the Supabase dashboard / trusted server-side Admin API. Never put a Supabase service-role key in browser code or commit it to GitHub.

## 3. Site configuration
Copy `supabase/config.example.js` to `supabase/config.js`, then enter:
- Project URL (Supabase Dashboard → Project Settings → API)
- Publishable/anon key from the same page

The publishable key is designed for browser use only when Row Level Security is enabled. Do not add the service-role/secret key to this file.

## 4. Hosting and framework
The existing site deploys to GitHub Pages and is plain HTML/CSS/JavaScript. For a full modern app framework with server routes and protected admin workflows, use **Next.js + Supabase + Vercel**. That requires moving deployment away from GitHub Pages and configuring Vercel environment variables. The schema in this repo is ready for that migration.

## 5. Data model
`projects`: UUID, title, category, description, tags, icon, sort order, published flag, and timestamps. RLS protects writes. Published rows are public; drafts can be hidden from visitors.
