-- Tableau de bord admin : l'admin voit tous les profils, mais seulement en lecture (il ne peut toujours
-- modifier/insérer que le sien, comme tout le monde). Identifié par son propre e-mail authentifié —
-- jamais par une clé "service_role", qui resterait un secret à ne jamais mettre dans l'application.
alter table public.profiles add column if not exists email text;

create policy "profiles_select_admin" on public.profiles
  for select using ((auth.jwt() ->> 'email') = 'ibrahimbaraia125@gmail.com');
