-- =============================================================
-- Pulso — políticas de Row Level Security (RLS)
-- Colar no Supabase → SQL Editor → Run
-- =============================================================
--
-- Contexto: app de utilizador único. Existe UMA conta Supabase
-- (a de AuthConfig) com que a app faz login silencioso. Estas
-- políticas dizem: "só pedidos autenticados podem ler/escrever".
-- A anon key sozinha (sem login) deixa de dar acesso aos dados.
--
-- Quando, no futuro, cada pessoa tiver a sua própria conta:
--   1. adicionar coluna:  user_id uuid not null default auth.uid()
--   2. trocar  (auth.role() = 'authenticated')
--      por     (user_id = auth.uid())
--      nas cláusulas USING e WITH CHECK.
-- =============================================================

-- ---------- GOALS ----------
alter table public.goals enable row level security;

drop policy if exists "pulso_goals_auth" on public.goals;
create policy "pulso_goals_auth"
  on public.goals
  for all
  to authenticated
  using (true)
  with check (true);

-- ---------- TASKS ----------
alter table public.tasks enable row level security;

drop policy if exists "pulso_tasks_auth" on public.tasks;
create policy "pulso_tasks_auth"
  on public.tasks
  for all
  to authenticated
  using (true)
  with check (true);

-- ---------- TRANSACTIONS ----------
alter table public.transactions enable row level security;

drop policy if exists "pulso_transactions_auth" on public.transactions;
create policy "pulso_transactions_auth"
  on public.transactions
  for all
  to authenticated
  using (true)
  with check (true);

-- =============================================================
-- Verificação rápida (opcional): deve devolver rowsecurity = true
-- para as três tabelas.
-- =============================================================
select relname as tabela, relrowsecurity as rls_ligado
from pg_class
where relname in ('goals', 'tasks', 'transactions')
order by relname;
