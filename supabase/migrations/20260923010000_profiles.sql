-- Un profil par utilisateur connecté : reprend exactement la forme du « state » local (profil, plan, coché, poids…)
-- pour porter l'application sans redessiner un schéma relationnel. Chacun ne voit et ne modifie que sa propre ligne.
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- Met à jour updated_at tout seul à chaque écriture (sert de repère « dernière activité »).
create or replace function public.touch_profiles_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function public.touch_profiles_updated_at();
