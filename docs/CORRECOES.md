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

---

# Objectivos v2 — arquivo automático e relatórios mensais — Setembro 2026

## Base de dados (schema v2 → v3)

- `Goals.archivedAt` (dateTime?, v3): objectivos a 100% são **arquivados**
  (saem da lista principal) em vez de apagados.
- Nova tabela `Reports` (`month`, `generatedAt`, `dataJson`) — histórico local
  de relatórios mensais.
- `onUpgrade` v2→v3: `addColumn(archivedAt)` + `createTable(reports)`.

## Arquivo de objectivos

- `goal_archive_service.dart`: `apply()` arquiva um objectivo a ≥100%
  (`isCompleted = true`, `archivedAt = agora`, cancela lembretes) e desarquiva
  se o progresso descer; `sweep()` varre todos (arranque + após guardar).
- `goal_providers.dart`: `goalsProvider` só devolve activos; novo
  `archivedGoalsProvider`.
- `goals_screen.dart`: menu (3 pontos, canto superior direito) com "Objectivos
  arquivados" e "Relatórios mensais"; **swipe** para eliminar (com confirmação)
  e menu por linha (Editar / Eliminar).
- Novo `archived_goals_screen.dart`.

## Relatórios mensais (módulo Objectivos)

- `report_service.dart`: `MonthlyReport` (concluídos no mês + activos com
  progresso), `ensureMonthlyReports()` gera os meses em falta no arranque
  (nunca o mês corrente), `expiredReports()` / `deleteReports()` para retenção.
- `report_pdf.dart`: exporta o relatório em **PDF** (resumo, tabela de
  concluídos, barras de progresso dos activos) via `printing`.
- `report_providers.dart`: `reportsProvider` (stream do histórico).
- Novos ecrãs `reports_screen.dart` (histórico) e `report_detail_screen.dart`.
- `home_screen.dart`: no arranque faz sweep de arquivo, gera relatórios em
  falta e **pergunta** antes de apagar relatórios com mais de 1 ano.

## Dependências

- `pdf` e `printing` adicionados.

## Verificação

- `dart analyze lib` → **No issues found**.
- Migração v2→v3 testada no Linux desktop (sem perda de dados).
- Nota: `printing` (exportar PDF) e as notificações agendadas só funcionam
  a sério no Android; no desktop são ignorados/no-op.

---

# Frontend dos Objectivos + splash — Setembro 2026

## Ecrã de Objectivos (`goals_screen.dart`)

- Lista passa a **cartões** agrupados por prazo (**Curto** / **Longo prazo**),
  ordenados pela data-alvo mais próxima.
- Cada cartão: faixa lateral com a **cor da importância**
  (Baixa=azul-cinza, Média=azul, Alta=laranja, Crítica=vermelho), **ponto de
  prazo** que muda de cor com a proximidade da data
  (verde >30d → amarelo ≤30d → laranja ≤7d → vermelho hoje/atrasado),
  barra de progresso, texto "faltam N d" / "atrasado N d", e botão **Concluir**
  (põe a 100% → arquiva).
- Swipe ou menu (3 pontos) para eliminar; estado vazio com ícone.

## Arranque robusto (`splash_screen.dart` + `auth_service.dart`)

- **Bug corrigido:** o arranque ficava preso quando a rede estava lenta —
  `signInWithPassword` não tinha timeout.
  - `AuthService.signIn()` agora tem `.timeout(8s)`.
  - `SplashScreen` corre `Future.wait([ Future.any([signIn(), delay(6s)]),
    delay(2.5s) ])` — abre **sempre** (offline inclusive) e fica visível no
    mínimo 2,5 s para a animação correr toda.

## Identidade visual

- **Wordmark:** "pulso" em **Familjen Grotesk** (700) com uma linha de
  batimento (ECG) por baixo, na cor de marca. Sem tagline.
- **Fonte da app:** **Hanken Grotesk** (`fontFamily` do tema).
  TTFs variáveis em `assets/fonts/` (OFL).
- **Paleta** (`lib/theme/pulso_theme.dart` → `PulsoColors` / `PulsoTheme`):
  primária `#2F6BED` (escuro `#5B8CFF`), tinta `#15171C`, neutro `#707784`,
  linha `#E7E9EE`, fundo `#F7F8FA` / `#0F1115`. Estado: sucesso `#1FA971`,
  aviso `#E8A13C`, erro `#E5484D` — separados da cor de marca.
- `main.dart` passa a usar `PulsoTheme.light()` / `PulsoTheme.dark()`.
- **Splash:** fundo do tema, wordmark, linha desenhada em `CustomPainter`
  (`_PulseLinePainter`) com animação de traçado + batida; respeita
  `MediaQuery.disableAnimations`.
- **Em falta (próximo):** `flutter_native_splash` (sem flash branco) e ícone
  de app a partir do símbolo.

## Verificação

- `dart analyze lib` → **No issues found**.
- Testado a correr no Linux desktop (fontes carregam, tema aplica).
