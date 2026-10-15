-- CricWorld: allow an admin to verify their own admin membership
create policy "Admins can view their own admin record"
on public.admin_users
for select
to authenticated
using (user_id = (select auth.uid()));

-- Admins can view drafts as well as published stories in the admin panel
create policy "Admins can view all news"
on public.news
for select
to authenticated
using (
  exists (
    select 1 from public.admin_users
    where user_id = (select auth.uid())
  )
);