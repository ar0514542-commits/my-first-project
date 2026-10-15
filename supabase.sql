-- Run in Supabase SQL Editor. Create your first user in Authentication > Users.
create table if not exists public.admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.articles (
 id uuid primary key default gen_random_uuid(),
 title text not null check (char_length(title) between 5 and 180),
 summary text not null default '',
 body text not null check (char_length(body) between 1 and 30000),
 category text not null default 'Cricket News',
 image_url text not null default '',
 status text not null default 'draft' check (status in ('draft','published')),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists articles_public_idx on public.articles(status,created_at desc);
alter table public.admins enable row level security;
alter table public.articles enable row level security;
create policy "Admin can see own role" on public.admins for select to authenticated using (user_id = (select auth.uid()));
create policy "Anyone reads published articles" on public.articles for select to anon, authenticated using (status = 'published' or exists (select 1 from public.admins where user_id = (select auth.uid())));
create policy "Admins insert" on public.articles for insert to authenticated with check (exists (select 1 from public.admins where user_id = (select auth.uid())));
create policy "Admins update" on public.articles for update to authenticated using (exists (select 1 from public.admins where user_id = (select auth.uid()))) with check (exists (select 1 from public.admins where user_id = (select auth.uid())));
create policy "Admins delete" on public.articles for delete to authenticated using (exists (select 1 from public.admins where user_id = (select auth.uid())));
-- After creating a user in Authentication > Users, grant admin access by replacing the UUID:
-- insert into public.admins(user_id) values ('YOUR-AUTH-USER-UUID');
