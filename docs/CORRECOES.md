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

## Seleção múltipla nos Objectivos

- Novo `goal_selection_provider.dart` (`Set<int>` de ids; vazio = modo desligado).
- `goals_screen.dart`: toque longo num cartão (ou menu → "Selecionar") entra em
  modo de seleção. AppBar contextual com contagem, **selecionar todos** e
  **eliminar** (com confirmação "Eliminar N objectivos?"). O X (ou o botão
  Voltar, via `PopScope`) sai do modo.
- Durante a seleção: cartão mostra círculo/check e destaque; toque alterna;
  swipe, FAB e botões por-cartão ficam ocultos para não haver conflito de gestos.
- Eliminar em lote cancela também os lembretes agendados de cada objectivo.

## Verificação

- `dart analyze lib` → **No issues found**.
- Testado a correr no Linux desktop (fontes carregam, tema aplica).

---

# Objectivos ↔ Tarefas: progresso automático — Setembro 2026

Quando um objectivo tem tarefas ligadas, o progresso deixa de ser manual:

    progresso = tarefas concluídas ÷ tarefas totais do objectivo  (arredondado)

Sem tarefas ligadas, o slider manual mantém-se. Não houve alteração de schema
(`Tasks.goalId` já existia).

- **Novo** `goal_progress_service.dart`: `recompute(ref, goalId)` recalcula o
  progresso, arquiva a 100% (ou desarquiva) e reagenda os lembretes;
  `recomputeAll(ref)` no arranque.
- `add_task_screen.dart`: dropdown **Objectivo (opcional)** + interruptor
  **Concluída**; ao guardar recalcula o objectivo novo e o antigo (se mudou).
- `tasks_screen.dart`: **checkbox** para concluir/reabrir a tarefa (recalcula o
  objectivo na hora), nome do objectivo no subtítulo, título riscado quando
  concluída.
- `add_goal_screen.dart`: com tarefas ligadas o slider dá lugar a um cartão
  "Progresso automático: X% — N de M tarefas"; o slider manual só aparece sem
  tarefas.
- `home_screen.dart`: `recomputeAll` no arranque para manter tudo sincronizado.

## Verificação

- `dart analyze lib` → **No issues found**.

---

# Módulos completos: identidade, Tarefas, Carteira — Setembro 2026

## Ícone + arranque nativo

- `assets/icon/` — símbolo Pulso (linha de batimento azul sobre tinta), gerado
  por `test/gen_icons_test.dart` (render `dart:ui` → PNG).
- `flutter_launcher_icons` gera ícones Android (mipmap + adaptive) e iOS.
- `flutter_native_splash` — fundo `#F7F8FA` / `#0F1115`, elimina o flash branco
  antes do Flutter carregar. Regenerar: `dart run flutter_native_splash:create`.

## Módulo Tarefas

- `tasks_screen` refeito: cartões com cor por prioridade, checkbox, chip,
  vencimento e objectivo ligado; **agrupado** por Atrasadas / Hoje / Esta
  semana / Depois / Sem data + Concluídas.
- **Seleção múltipla** (`task_selection_provider`): concluir ou eliminar em lote.
- **Filtros** (`task_filter_provider`): prioridade, objectivo, mostrar concluídas.
- **Notificações agendadas** (`task_reminder_service`): véspera às 18h e dia às
  9h; canceladas ao concluir/eliminar; `rescheduleAll` no arranque e ao guardar.

## Módulo Carteira

Base de dados **v3 → v4**: nova tabela `Budgets`; `Reports.type`
(`objectivos` | `financeiro`).

- **Editar transações**: `add_transaction_screen` passa a criar e editar
  (`updateTransactionProvider`). `finance_screen`: toque = editar, swipe =
  eliminar, mostra a origem (M-Pesa/BIM/SMS).
- **Gráfico no ecrã**: secção "Gastos deste mês" (barras por categoria,
  `currentMonthExpensesByCategoryProvider`).
- **Orçamentos** (`budgets_screen`, `budget_providers`): limite mensal por
  categoria, barra de progresso do gasto do mês, marca de ultrapassado; banner
  na Carteira quando algum é ultrapassado.
- **Relatório financeiro** (`FinancialReport`): receitas/despesas/saldo/por
  categoria. `ensureMonthlyReports` gera objectivos **e** financeiro por mês.
  `reports_screen` e `report_detail_screen` distinguem os tipos; `report_pdf`
  ganhou o layout financeiro. Acesso pelo menu da Carteira e dos Objectivos.

## Ainda por fazer

- Relatório mensal de **tarefas**.

## Verificação

- `dart analyze lib` → **No issues found**.
- `flutter build linux --debug` OK; migração v3→v4 testada a correr no Linux.

---

# Ler notificações push de apps bancárias — Setembro 2026

Além das SMS, a app passa a poder ler as **notificações push** de apps de
banco/carteira (M-Pesa, e-Mola, mKesh, Millennium bim, etc.) e criar
transações. **Só Android.**

- Dependência `notification_listener_service`.
- **Novo** `transaction_ingest_service.dart` — ponto único onde SMS **e** push
  viram transações: analisa o texto (`SmsParser`), **evita duplicados** pela
  referência (`smsId`) e grava. `sms_service` foi simplificado para o usar.
- **Novo** `bank_notification_service.dart` — subscreve
  `NotificationListenerService.notificationsStream`, ignora notificações
  removidas/persistentes, e passa `título + conteúdo` ao ingest. O parser é
  restritivo (exige valor + verbo), por isso raramente apanha lixo.
- `AndroidManifest.xml` — declara o `NotificationListener` service com
  `BIND_NOTIFICATION_LISTENER_SERVICE`.
- `settings_screen.dart` — tile **"Ler notificações bancárias"**: mostra o
  estado e abre as Definições do Android para conceder o acesso.
- `home_screen.dart` — arranca o listener no Android se a permissão já estiver
  concedida.

**Limitações:** funciona enquanto a app está viva (sem isolate de fundo
dedicado); a origem fica marcada como `… · push`. iOS não permite ler
notificações de outras apps.

## Verificação

- `dart analyze lib` → **No issues found**.
- `flutter build linux --debug` OK; corre no Linux sem erros (o listener é
  ignorado fora do Android). Falta testar num Android real.

---

# Login real (sem credenciais embutidas) — Setembro 2026

O repositório ficou público, o que tornava arriscado continuar com um login
automático de credenciais fixas embutidas na app. Substituído por autenticação
real:

- **Novo** `login_screen.dart`: entrar / criar conta (Supabase Auth) com
  validação, mensagens de erro legíveis, e botão **"Continuar sem conta"**
  (a app funciona sempre offline com a BD local).
- `auth_service.dart` reescrito: `signIn`/`signUp`/`signOut`/`isLoggedIn`/
  `currentUser`. Sem `AuthConfig`, sem password nenhuma no código.
- `splash_screen.dart`: já não faz login silencioso; só decide, ao fim da
  animação, entre `HomeScreen` (sessão já activa — persistida pelo próprio
  `supabase_flutter`) e `LoginScreen`.
- `settings_screen.dart`: novo cartão de conta no topo — mostra o email
  ligado, "Sair" (com confirmação) ou "Entrar".
- Removidos `lib/config/auth_config.dart`/`.example.dart` e as chaves
  `AUTH_EMAIL`/`AUTH_PASSWORD`. `secrets.example.json` fica só com
  `SUPABASE_URL`/`SUPABASE_ANON_KEY` (não são segredo — RLS é a proteção real).
- Password antiga (que esteve em texto no histórico do git) já tinha sido
  rodada — ver `docs/SEGURANCA.md`.

## Verificação

- `dart analyze lib` → **No issues found**.

---

# Tarefas-hábito (check-in diário) — Setembro 2026

Novo tipo de tarefa: em vez de uma data de vencimento única, tem um
**período** (início→fim) e pede um **check-in diário**; o progresso é a
percentagem de dias marcados.

## Base de dados (schema v4 → v5)

- `Tasks`: `isHabit`, `habitStartDate`, `habitEndDate`, `reminderHour`,
  `reminderMinute`, `habitClosed`.
- Nova tabela `HabitCheckins` (`taskId`, `date`, `createdAt`) — um registo por
  dia marcado.

## Serviços

- **Novo** `habit_service.dart`: `totalDias`, `diasFeitos`, `percent`,
  `feitoHoje`, `alternarHoje` (marca/desmarca o dia de hoje e recalcula o
  objectivo ligado), `sweepClose` (fecha sozinho os hábitos cujo período já
  terminou: `habitClosed = true`, `isCompleted = true`, cancela lembretes).
- `task_reminder_service.dart`: agenda uma notificação por dia à hora
  escolhida, do hoje até ao fim do período (janela rolante de 90 dias, como
  os objectivos). Faixa de ids própria (`700000 + taskId*100`) para não
  colidir com os lembretes de vencimento.
- `goal_progress_service.dart` **reescrito**: o progresso de um objectivo
  passa a ser a **média da percentagem de cada tarefa** — tarefa normal conta
  0/100%, tarefa-hábito conta a sua própria percentagem (mesmo antes de
  fechar). Antes era só "concluídas ÷ total".

## UI

- `add_task_screen.dart`: interruptor **"Tarefa-hábito"** (só ao criar) que
  troca a data única por **início**, **fim** e **hora do lembrete diário**.
- `tasks_screen.dart`: hábitos activos têm secção própria no topo
  ("Hábitos"), cartão com barra de progresso, "X de Y dias" e botão
  **"Marcar hoje"** / **"Feito hoje"**; hábitos fechados aparecem em
  "Concluídas" com o resultado final riscado.
- `home_screen.dart`: `HabitService.sweepClose` no arranque.

## Verificação

- `dart analyze lib` → **No issues found**.
- `flutter build linux --debug` OK; migração v4→v5 testada a correr no Linux.

---

# Prazo automático + progresso não editável — Setembro 2026

## Objectivos: prazo calculado, não escolhido

- **Novo** `goal_term_service.dart`: `compute(targetDate)` devolve
  `Curto prazo` (≤30 dias), `Médio prazo` (≤~6 meses) ou `Longo prazo`
  (mais); `recomputeAll(ref)` actualiza todos os objectivos activos no
  arranque, para um objectivo "amadurecer" sozinho (Longo→Médio→Curto) à
  medida que a data se aproxima.
- `add_goal_screen.dart`: o dropdown manual de Prazo foi removido; mostra
  antes o prazo calculado como texto por baixo da data-alvo.
- `goals_screen.dart`: nova secção **"Médio prazo"** entre Curto e Longo.
- `home_screen.dart`: `GoalTermService.recomputeAll` no arranque.
- Sem alteração de schema (a coluna `term` já existia; só mudou como o valor
  é decidido).

## Objectivos: progresso deixa de poder ser editado à mão

- `add_goal_screen.dart`: removido o slider manual, em criação e edição.
  Objectivo novo começa sempre a 0%; a edição nunca mexe no valor guardado.
- Sem tarefas ligadas, o cartão mostra "Sem tarefas ligadas" e o valor fica
  congelado (0% num objectivo novo) até se ligar uma tarefa/hábito.
- `GoalProgressService` continua a ser o único a mudar
  `progressPercentage`, a partir das tarefas ligadas.

## Verificação

- `dart analyze lib` → **No issues found**.
- `flutter build linux --debug` OK. Sem migração de schema.

---

# Ordem dos separadores — Setembro 2026

`home_screen.dart`: **Tarefas** passa a ser o primeiro separador (antes de
Objectivos), por ser o ecrã de uso mais frequente. Ordem actual: Tarefas ·
Objectivos · Finanças · Estatísticas · Configurações.
