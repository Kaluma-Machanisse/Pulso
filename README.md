# Pulso

App pessoal de **lembretes, objectivos e educação financeira**, com foco no
contexto moçambicano (Metical, leitura de SMS M-Pesa/BIM). Flutter + SQLite
local (Drift) e sincronização opcional com Supabase.

## Funcionalidades

- **Objectivos** com categoria, data-alvo e progresso.
- **Tarefas** com prioridade e vencimento, opcionalmente ligadas a um objectivo.
- **Carteira**: receitas/despesas, saldo, filtros por tipo, categoria, mês e ano.
- **Leitura automática de SMS** de M-Pesa e BIM → cria transações.
- **Estatísticas**: gráfico mensal receitas vs despesas + progresso dos objectivos.
- **Lembretes locais** para tarefas a vencer e objectivos parados.
- **Configurações**: tema (claro/escuro/sistema), moeda, backup JSON local.
- **Sincronização** mirror com Supabase (push/pull manual).

## Arranque rápido

```bash
cp lib/config/auth_config.example.dart     lib/config/auth_config.dart
cp lib/config/supabase_config.example.dart lib/config/supabase_config.dart
# preencher os valores nos dois ficheiros (ou usar --dart-define)

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Documentação

- [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) — stack, modelo de dados, ecrãs, providers, serviços, sincronização, build.
- [`docs/SEGURANCA.md`](docs/SEGURANCA.md) — checklist de segurança e acções manuais pendentes.
- [`docs/CORRECOES.md`](docs/CORRECOES.md) — registo da última ronda de correcções.

## Estado

Projecto pessoal em desenvolvimento. A sincronização actual assume **um único
utilizador / uma conta Supabase partilhada** — ver limitações e plano de
evolução em `docs/ARQUITECTURA.md` §7.
