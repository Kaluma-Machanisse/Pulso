-- =============================================================
-- Pulso — migração v2 da tabela `goals` no Supabase
-- Colar no Supabase → SQL Editor → Run
-- =============================================================
--
-- A app passou a ter dois campos novos nos objectivos:
--   importance : 'Baixa' | 'Média' | 'Alta' | 'Crítica'
--   term       : 'Curto prazo' | 'Longo prazo'
--
-- Sem estas colunas, o push/pull de objectivos para o Supabase
-- vai falhar. Correr uma única vez.
-- =============================================================

alter table public.goals
  add column if not exists importance text not null default 'Média';

alter table public.goals
  add column if not exists term text not null default 'Curto prazo';

-- Verificação
select column_name, data_type, column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'goals'
order by ordinal_position;
