-- ============================================================
--  PI-Zeiterfassung – Datenbankschema für Supabase
--  Einmalig im Supabase-Dashboard unter "SQL Editor" ausführen.
-- ============================================================

-- Features / RUN-Themen / Sonstiges
create table if not exists public.features (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name        text not null,
  category    text not null check (category in ('feature', 'run', 'other')),
  archived    boolean not null default false,
  created_at  timestamptz not null default now()
);

-- Zeiteinträge (end_at = null bedeutet: läuft gerade)
create table if not exists public.entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  feature_id  uuid not null references public.features(id) on delete cascade,
  start_at    timestamptz not null,
  end_at      timestamptz,
  created_at  timestamptz not null default now(),
  check (end_at is null or end_at > start_at)
);

create index if not exists entries_user_start_idx on public.entries (user_id, start_at desc);
create index if not exists features_user_idx on public.features (user_id);

-- ------------------------------------------------------------
--  Zugriffsrechte für angemeldete Nutzer (Postgres-Ebene)
-- ------------------------------------------------------------
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.features to authenticated;
grant select, insert, update, delete on public.entries  to authenticated;

-- ------------------------------------------------------------
--  Row Level Security: jeder Nutzer sieht und ändert nur seine Daten
-- ------------------------------------------------------------
alter table public.features enable row level security;
alter table public.entries  enable row level security;

drop policy if exists "features: eigene Zeilen" on public.features;
create policy "features: eigene Zeilen" on public.features
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "entries: eigene Zeilen" on public.entries;
create policy "entries: eigene Zeilen" on public.entries
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ------------------------------------------------------------
--  Realtime: Änderungen live auf alle offenen Geräte pushen
-- ------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'features'
  ) then
    alter publication supabase_realtime add table public.features;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'entries'
  ) then
    alter publication supabase_realtime add table public.entries;
  end if;
end $$;

-- Damit Realtime bei Updates/Deletes die alten Werte mitliefert
alter table public.features replica identity full;
alter table public.entries  replica identity full;
