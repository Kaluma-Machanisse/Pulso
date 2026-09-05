# Correcções de manutenção — Setembro 2026

Ronda de correcções de bugs, segurança e robustez. Nada aqui muda o
`schemaVersion` da base de dados nem exige `build_runner`.

## Segurança / repositório

- `.gitignore`: passa a ignorar `*.zip`, `pulso_backup.json`, `android/build/`,
  `android/.gradle/`.
- `lib.zip` apagado do disco.
- `lib/config/auth_config.dart` e `supabase_config.dart` reescritos para
  aceitarem `--dart-define` (`String.fromEnvironment`) mantendo valores por
  omissão. Criados `auth_config.example.dart` e `supabase_config.example.dart`
  como modelos versionados.
- Acções manuais que faltam (rodar password, activar RLS): ver `docs/SEGURANCA.md`.

## Sincronização (`lib/services/sync_service.dart`)

- **Duplicação eliminada:** o antigo `upsert` sem `onConflict` comportava-se
  como `insert` e duplicava tudo a cada sync. Agora cada `push` faz
  `delete` + `insert` em lote (estratégia mirror).
- **Perda de dados no pull evitada:** o pull agora busca o remoto para memória
  primeiro e só depois apaga/reinsere o local **dentro de `db.transaction`**.
- Todos os métodos passam a devolver `bool` (sucesso/falha) em vez de `void`.

## Feedback de erros na UI

- `finance_screen.dart`: botão de sync mostra spinner e SnackBar de sucesso
  **ou** de falha (antes dizia sempre "Sincronização completa").
- `stats_screen.dart`: botão de pull idem.
- `settings_screen.dart`: export/import de backup mostram resultado real
  (`BackupResult.sucesso` / `semFicheiro` / `erro`).

## Bugs funcionais

- `sms_service.dart`: `_processSms` era `void` e chamava
  `ref.read(addTransactionProvider(...))` **sem `.future`** — a transação podia
  nunca ser gravada. Agora é `async` e faz `await ... .future`. Além disso,
  guarda a `reference` da SMS em `smsId`.
- `stats_screen.dart`: `maxY` do gráfico somava receitas+despesas (barras estão
  lado a lado, não empilhadas), dando escala errada. Agora usa o maior valor
  individual × 1.1, com guarda para dataset vazio.
- `reminder_service.dart`: passa a respeitar o interruptor
  `notificationsEnabled` das Configurações (antes notificava sempre).
- `main.dart`: `ThemeData` migrado para Material 3
  (`useMaterial3`, `ColorScheme.fromSeed`); removidos imports comentados.
- `database.dart`: adicionada `MigrationStrategy` explícita (base para futuras
  migrações). `PRAGMA foreign_keys` deixado desligado de propósito — ver
  `docs/ARQUITECTURA.md` §7.

## UX

- Novo `lib/widgets/confirm_dialog.dart` (`confirmarEliminacao`).
- `goals_screen.dart`, `tasks_screen.dart`, `finance_screen.dart`: eliminar por
  toque longo agora pede confirmação e faz `await ... .future`.
- `settings_screen.dart`: restaurar backup pede confirmação (é destrutivo).
- `finance_screen.dart`: adicionados filtros de **mês** e **ano** (o
  `financeFilterProvider` já os suportava mas não havia UI) + botão "limpar
  filtros". Saldo e valores passam a usar a moeda escolhida nas Configurações.

## Dependências

- `google_fonts` removido do `pubspec.yaml` (não era usado).

## Verificação

- `dart analyze lib` → **No issues found**.
- Sem alterações a `*.g.dart`; `build_runner` não é necessário para esta ronda.

---

# Objectivos v1 — importância, prazo e lembretes agendados — Setembro 2026

## Base de dados (schema v1 → v2)

- `Goals` ganha `importance` (`Baixa`/`Média`/`Alta`/`Crítica`, default `Média`)
  e `term` (`Curto prazo`/`Longo prazo`, default `Curto prazo`).
- `schemaVersion = 2`; `onUpgrade` faz `m.addColumn(...)` — migração automática,
  sem perda de dados.
- `database.g.dart` regenerado com `dart run build_runner build`.
- Supabase: a tabela `goals` remota precisa das mesmas colunas —
  `docs/supabase_migracao_v2.sql`.

## Notificações

- `notification_service.dart`: inicializa o `timezone` (fixo em `Africa/Maputo`)
  e ganha `scheduleAt`, `cancel`, `cancelRange`. `zonedSchedule` em modo
  **inexacto** (sem permissão `SCHEDULE_EXACT_ALARM`).
- **Novo** `goal_reminder_service.dart`: agenda os lembretes de cada objectivo:
  - 1–4 lembretes por semana conforme a importância;
  - +1 no dia exacto da data-alvo;
  - janela de 90 dias, reagendada a cada arranque;
  - cancela ao completar/eliminar.
- `home_screen.dart`: chama `GoalReminderService.rescheduleAll` no arranque;
  SMS init agora protegido por `Platform.isAndroid` (não rebenta no desktop).
- `AndroidManifest.xml`: `RECEIVE_BOOT_COMPLETED`, `VIBRATE` e os receivers
  `ScheduledNotification[Boot]Receiver` do plugin.

## UI

- `add_goal_screen.dart`: dropdowns **Importância** (com dica da frequência) e
  **Prazo**; após guardar, reagenda os lembretes.
- `goals_screen.dart`: subtítulo mostra importância e prazo; eliminar cancela
  os lembretes agendados.

## Outros

- `backup_service.dart` e `sync_service.dart`: incluem `importance`/`term` no
  export/import e no push/pull.

## Verificação

- `dart analyze lib` → **No issues found**.
- Migração v1→v2 testada a correr no Linux desktop (sem perda de dados; o
  agendamento é ignorado no desktop, como esperado).
