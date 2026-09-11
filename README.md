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
- **Login** com email/password (Supabase Auth) + **sincronização** mirror
  (push/pull manual). Sem conta, a app funciona só localmente.

## Arranque rápido

Repositório público — **nenhuma credencial fica em texto no código**. O login
é feito pelo utilizador no ecrã da app (email/password reais, geridos pelo
Supabase Auth); só a ligação ao projecto Supabase (URL + anon key, públicas
por design) entra por `--dart-define-from-file`:

```bash
cp secrets.example.json secrets.json
# preenche secrets.json com o URL e a anon key do teu projecto Supabase

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define-from-file=secrets.json
```

`lib/config/supabase_config.dart` é opcional — só serve se preferires um
ficheiro local em vez de `--dart-define` (ver `supabase_config.example.dart`).
Fica fora do controlo de versões (`.gitignore`).

## Documentação

- [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) — stack, modelo de dados, ecrãs, providers, serviços, sincronização, build.
- [`docs/SEGURANCA.md`](docs/SEGURANCA.md) — checklist de segurança e acções manuais pendentes.
- [`docs/CORRECOES.md`](docs/CORRECOES.md) — registo da última ronda de correcções.

## Estado

Projecto pessoal em desenvolvimento. A sincronização actual assume **um único
utilizador / uma conta Supabase partilhada** — ver limitações e plano de
evolução em `docs/ARQUITECTURA.md` §7.
