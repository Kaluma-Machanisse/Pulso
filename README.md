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

Repositório público — **nenhum segredo fica em texto no código**. As
credenciais entram por `--dart-define-from-file`:

```bash
cp secrets.example.json secrets.json
# preenche secrets.json com os teus valores (fica fora do git)

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define-from-file=secrets.json
```

`lib/config/auth_config.dart` e `supabase_config.dart` são opcionais — só
servem se preferires um ficheiro local em vez de `--dart-define` (ver os
`*.example.dart` correspondentes). Ambas as formas ficam fora do controlo de
versões (`.gitignore`).

## Documentação

- [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) — stack, modelo de dados, ecrãs, providers, serviços, sincronização, build.
- [`docs/SEGURANCA.md`](docs/SEGURANCA.md) — checklist de segurança e acções manuais pendentes.
- [`docs/CORRECOES.md`](docs/CORRECOES.md) — registo da última ronda de correcções.

## Estado

Projecto pessoal em desenvolvimento. A sincronização actual assume **um único
utilizador / uma conta Supabase partilhada** — ver limitações e plano de
evolução em `docs/ARQUITECTURA.md` §7.
