-- Soumojit Basu portfolio: Supabase/Postgres schema
-- Run this in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 120),
  category text not null check (category in ('quant', 'ml', 'data')),
  description text not null check (char_length(description) between 1 and 2000),
  tags text[] not null default '{}',
  icon text not null default '◇',
  sort_order integer not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

drop trigger if exists projects_updated_at on public.projects;
create trigger projects_updated_at before update on public.projects
for each row execute function public.set_updated_at();

alter table public.projects enable row level security;

-- Visitors can read published projects only.
drop policy if exists "Anyone can read published projects" on public.projects;
create policy "Anyone can read published projects"
on public.projects for select to anon, authenticated
using (published = true);

-- Admins can also read unpublished drafts in the dashboard.
drop policy if exists "Admins can read all projects" on public.projects;
create policy "Admins can read all projects"
on public.projects for select to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Only signed-in users can create, edit, or delete. Restrict admin access
-- by setting app_metadata.role = 'admin' for your own Supabase user.
drop policy if exists "Admins can insert projects" on public.projects;
create policy "Admins can insert projects"
on public.projects for insert to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Admins can update projects" on public.projects;
create policy "Admins can update projects"
on public.projects for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Admins can delete projects" on public.projects;
create policy "Admins can delete projects"
on public.projects for delete to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Starter records. Safe to run once; titles are used to avoid duplicate seed rows.
insert into public.projects (title, category, description, tags, icon, sort_order)
values
('Options pricing & Greeks', 'quant', 'Implement and compare Black–Scholes option prices, Greeks, and sensitivity to volatility and time to expiry.', array['Python','Black–Scholes','Options'], '◇', 1),
('Market strategy backtesting', 'quant', 'Build a reproducible backtesting workflow for intraday market data, signals, and risk-adjusted performance.', array['Python','Backtesting','Risk'], '↗', 2),
('Machine learning experiments', 'ml', 'Explore model training, feature engineering, evaluation, and validation for applied prediction problems.', array['Python','Machine Learning','Evaluation'], '⌘', 3),
('Optimization & decision systems', 'data', 'Explore constrained optimization, sensitivity analysis, and model-driven decision-making.', array['Operations Research','Optimization','Decision science'], '◇', 4)
on conflict do nothing;
