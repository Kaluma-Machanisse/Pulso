# Pulso — Arquitectura e construção da app

App pessoal de **lembretes, objectivos e educação financeira**, pensada para
o contexto moçambicano (Metical, M-Pesa, BIM). Flutter + Drift (SQLite local)
com sincronização opcional para Supabase.

- **Plataformas alvo:** Android (principal), com projectos iOS/Linux/macOS/Windows/Web gerados.
- **Versão:** `1.0.0+1` (`pubspec.yaml`)
- **SDK:** Dart `>=3.8.0 <4.0.0`, Flutter stable 3.44+

---

## 1. Stack

| Camada | Tecnologia | Porquê |
|---|---|---|
| UI | Flutter Material 3 | `ColorScheme.fromSeed(Colors.blue)`, tema claro/escuro/sistema |
| Estado | `flutter_riverpod` ^2.6 | Providers reactivos, `StreamProvider` sobre a BD |
| BD local | `drift` ^2.26 + `sqlite3_flutter_libs` | Fonte de verdade offline, streams reactivas |
| Nuvem | `supabase_flutter` ^2.12 | Auth + tabelas espelho (`goals`, `tasks`, `transactions`) |
| Preferências | `shared_preferences` | Tema, moeda, interruptor de notificações |
| Notificações | `flutter_local_notifications` ^18 + `timezone` | Lembretes locais |
| SMS | `telephony` ^0.2 + `permission_handler` ^12 | Ler SMS de M-Pesa/BIM e criar transações |
| Gráficos | `fl_chart` ^1.2 | Barras receitas/despesas |

---

## 2. Estrutura de pastas (`lib/`)

```
lib/
├─ main.dart                  Bootstrap: Supabase.initialize + Notificações + ProviderScope
├─ config/
│  ├─ auth_config.dart          (GITIGNORED) credenciais do utilizador de serviço
│  ├─ supabase_config.dart      (GITIGNORED) URL + anon key
│  └─ *.example.dart            Modelos versionados
├─ database/
│  ├─ database.dart             Tabelas Drift + AppDatabase + MigrationStrategy
│  └─ database.g.dart           GERADO por build_runner (não editar à mão)
├─ providers/                 Camada Riverpod (ver §5)
├─ services/                  Lógica sem UI (ver §6 e §10)
├─ screens/                   Ecrãs (ver §4)
├─ theme/
│  └─ pulso_theme.dart          Paleta (`PulsoColors`) + temas claro/escuro (`PulsoTheme`)
└─ widgets/
   └─ confirm_dialog.dart      Diálogo genérico de confirmação de eliminação

assets/fonts/                  Hanken Grotesk (app) + Familjen Grotesk (wordmark)
```

---

## 3. Modelo de dados (`lib/database/database.dart`)

`schemaVersion = 3`. Quatro tabelas, todas com `id` autoincrement.

### Goals (Objectivos)
| Campo | Tipo | Notas |
|---|---|---|
| title | text | obrigatório |
| description | text? | |
| targetDate | dateTime? | data alvo |
| category | text | default `Geral` (Saúde, Financeiro, Carreira, Pessoal) |
| progressPercentage | int | 0–100. **Automático** quando o objectivo tem tarefas ligadas (= % de tarefas concluídas); manual (slider) caso não tenha |
| isCompleted | bool | default `false` |
| importance | text | **v2** — `Baixa`/`Média`/`Alta`/`Crítica`; define a frequência de lembretes (1/2/3/4 por semana). Default `Média` |
| term | text | **v2** — `Curto prazo`/`Longo prazo`; organização/filtro. Default `Curto prazo` |
| archivedAt | dateTime? | **v3** — preenchido quando o objectivo chega a 100%. Se `!= null`, sai da lista principal (fica em "Objectivos arquivados"). Não se apagam objectivos concluídos |

### Reports (Relatórios mensais) — v3
| Campo | Tipo | Notas |
|---|---|---|
| month | text | `'AAAA-MM'` a que o relatório diz respeito |
| generatedAt | dateTime | quando foi gerado |
| dataJson | text | conteúdo serializado (`MonthlyReport.toJson`) |

> Só existe o relatório de **Objectivos** por agora. Relatórios financeiros e de
> tarefas virão depois, na mesma tabela (o `dataJson` acomoda os campos novos).

### Tasks (Tarefas)
| Campo | Tipo | Notas |
|---|---|---|
| title | text | obrigatório |
| description | text? | |
| dueDate | dateTime? | vencimento |
| priority | text | default `Média` (Alta / Média / Baixa) |
| isCompleted | bool | default `false` |
| goalId | int? | referência a `Goals.id` (ver limitação em §7) |

### Transactions (Transações)
| Campo | Tipo | Notas |
|---|---|---|
| amount | real | **valor sempre positivo**; o sinal é dado por `type` |
| type | text | `receita` ou `despesa` |
| category | text | default `Geral` |
| description | text? | |
| date | dateTime | data da transação |
| source | text | `manual`, `M-Pesa`, `BIM`, … |
| smsId | text? | referência da SMS original (evita duplicados no futuro) |
| goalId | int? | referência opcional a um objectivo |

> **Convenção de sinais:** `amount` guarda sempre um número positivo.
> `balanceProvider` soma quando `type == 'receita'` e subtrai quando `despesa`.
> Não guardar valores negativos na coluna.

### Migrações

`MigrationStrategy` está definida com `onCreate`/`onUpgrade`.

- **v1 → v2:** `onUpgrade` faz `m.addColumn(goals, goals.importance)` e
  `m.addColumn(goals, goals.term)`. Os objectivos existentes ficam com os
  valores por omissão. Sem perda de dados.
- Se sincronizares com o Supabase, a tabela `goals` remota também precisa das
  colunas — ver `docs/supabase_migracao_v2.sql`.
- **v2 → v3:** `m.addColumn(goals, goals.archivedAt)` + `m.createTable(reports)`.
  A tabela `Reports` é só local (não sincroniza).

Sempre que mudares colunas:

1. Incrementa `schemaVersion`.
2. Adiciona os passos em `onUpgrade` (`m.addColumn(...)`, etc.).
3. Regenera o código: `dart run build_runner build --delete-conflicting-outputs`.

`PRAGMA foreign_keys` está **desligado de propósito** (ver §7).

---

## 4. Ecrãs (`lib/screens/`)

| Ecrã | Tipo | Função |
|---|---|---|
| `splash_screen.dart` | Stateful | Delay 500ms → `AuthService.signIn()` → `HomeScreen` |
| `home_screen.dart` | ConsumerStateful | `BottomNavigationBar` com 5 abas; no arranque chama `SmsService.initialize` + `ReminderService.checkAndNotify` |
| `goals_screen.dart` | ConsumerWidget | Objectivos **activos** em **cartões** agrupados por prazo (Curto/Longo), ordenados pela data-alvo mais próxima. Cada cartão: faixa lateral com a **cor da importância**, **ponto de prazo** que muda de cor à medida que a data se aproxima (verde→amarelo→laranja→vermelho/atrasado), barra de progresso, contagem de dias, botão **Concluir** (põe a 100% → arquiva). Swipe ou menu (3 pontos) = eliminar; menu do AppBar → arquivados / relatórios. **Seleção múltipla**: toque longo (ou menu → Selecionar) abre o modo; AppBar contextual com contagem, selecionar todos e eliminar em lote |
| `archived_goals_screen.dart` | ConsumerWidget | Objectivos concluídos (arquivados); toque = ver/editar, toque longo = apagar de vez |
| `add_goal_screen.dart` | ConsumerStateful | Formulário criar/editar objectivo (título, descrição, categoria, **importância**, **prazo**, data, progresso). Ao guardar: sweep de arquivo + reagenda lembretes |
| `reports_screen.dart` | ConsumerWidget | Histórico de relatórios mensais; toque = detalhe, botão = exportar PDF, toque longo = apagar |
| `report_detail_screen.dart` | StatelessWidget | Relatório de um mês (resumo + concluídos + progresso dos activos) + exportar PDF |
| `tasks_screen.dart` | ConsumerWidget | Lista tarefas com **checkbox** para concluir/reabrir (recalcula o progresso do objectivo ligado); mostra o objectivo no subtítulo; toque = editar, toque longo = eliminar |
| `add_task_screen.dart` | ConsumerStateful | Formulário criar/editar tarefa: título, descrição, prioridade, **objectivo (opcional)**, **concluída**, data. Ao guardar recalcula o progresso do objectivo novo e do antigo |
| `finance_screen.dart` | ConsumerStateful | Saldo + lista filtrável (tipo, categoria, mês, ano) + botão de push para Supabase com feedback de sucesso/erro |
| `add_transaction_screen.dart` | ConsumerStateful | Formulário nova transação (receita/despesa) |
| `stats_screen.dart` | ConsumerWidget | Gráfico de barras mensal + progresso dos objectivos + botão de pull do Supabase |
| `settings_screen.dart` | ConsumerWidget | Tema, moeda, backup/restauro JSON (com confirmação), interruptor de notificações |

---

## 5. Providers (`lib/providers/`)

| Ficheiro | Providers | Papel |
|---|---|---|
| `database_provider.dart` | `databaseProvider` | Instância única de `AppDatabase` |
| `goal_providers.dart` | `goalsProvider` (activos), `archivedGoalsProvider`, `addGoalProvider`, `updateGoalProvider`, `deleteGoalProvider` | CRUD de objectivos |
| `goal_selection_provider.dart` | `goalSelectionProvider` (`Set<int>`) | Ids selecionados no modo de seleção múltipla (vazio = desligado) |
| `task_providers.dart` | `tasksProvider` (stream), `addTaskProvider`, `updateTaskProvider`, `deleteTaskProvider`, `tasksByGoalProvider` | CRUD de tarefas |
| `transaction_providers.dart` | `transactionsProvider`, `addTransactionProvider`, `deleteTransactionProvider`, `balanceProvider`, `filteredTransactionsProvider` | CRUD + saldo + lista filtrada |
| `filter_providers.dart` | `financeFilterProvider` (`StateNotifier`) | Estado dos filtros: `type`, `category`, `month`, `year`, `reset()` |
| `settings_providers.dart` | `settingsProvider` (`StateNotifier`) | `themeMode`, `currency`, `notificationsEnabled`, persistidos em `SharedPreferences` |
| `stats_providers.dart` | `monthlyStatsProvider`, `goalsProgressProvider` | Agregação `ano-mês → {receitas, despesas}` e progresso |

> **Regra Riverpod:** um `FutureProvider.family` só executa quando é
> observado. Ao disparar mutações (add/update/delete) usar sempre
> `await ref.read(provider(arg).future)`.

---

## 6. Serviços (`lib/services/`)

| Serviço | Responsabilidade |
|---|---|
| `auth_service.dart` | `signIn()` — login silencioso com credenciais fixas; reusa a sessão se ainda válida |
| `notification_service.dart` | `initialize()` — canal Android + fuso horário (`Africa/Maputo`); `showNotification()` imediata; `scheduleAt()` agenda uma única no futuro (`zonedSchedule`, modo inexacto); `cancel()`/`cancelRange()` |
| `goal_reminder_service.dart` | Agenda os lembretes de cada objectivo conforme a **importância** (1–4/semana) + 1 no dia da data-alvo; janela de 90 dias; `rescheduleForGoal`, `rescheduleAll` (arranque), `cancelForGoal` (ao eliminar). Ver §10 |
| `goal_archive_service.dart` | Arquiva objectivos a 100% (`archivedAt`), desarquiva se o progresso descer; `apply()` / `sweep()` |
| `goal_progress_service.dart` | Progresso automático = tarefas concluídas ÷ totais do objectivo. `recompute(goalId)` (após mexer numa tarefa), `recomputeAll()` (arranque). Chama `GoalArchiveService.apply` + `rescheduleForGoal` |
| `report_service.dart` | `MonthlyReport` (objectivos concluídos no mês + activos), gera os meses em falta no arranque, retenção de 1 ano |
| `report_pdf.dart` | Exporta um `MonthlyReport` para PDF (via `printing`) |
| `reminder_service.dart` | `checkAndNotify(ref)` — verificação **ao abrir a app**: respeita `notificationsEnabled`; notifica tarefas a vencer hoje/amanhã e objectivos <50% com data-alvo em ≤7 dias. Complementa (não substitui) os lembretes agendados |
| `sms_service.dart` | Pede permissão SMS, escuta mensagens recebidas, passa por `SmsParser` e grava a transação (`await ... .future`) |
| `sms_parser.dart` | Regras regex para **M-Pesa** e **BIM**: extrai `amount`, `type` (receita/despesa), `reference` |
| `backup_service.dart` | `exportToJson` / `importFromJson` para `pulso_backup.json` nos documentos da app; importação dentro de transação; devolve `BackupResult` |
| `sync_service.dart` | Sincronização **mirror** com Supabase (ver §7); todos os métodos devolvem `bool` |

---

## 7. Sincronização — estado actual e evolução

### Como funciona hoje (estratégia "mirror", app de utilizador único)

- **Push** (`SyncService.pushAll`): para cada tabela, apaga tudo no Supabase e
  reinsere as linhas locais **num único `insert` em lote**.
- **Pull** (`SyncService.pullAll`): busca as linhas remotas para memória e só
  depois, **dentro de uma `db.transaction`**, apaga o local e reinsere.
- Qualquer falha é apanhada, registada com `debugPrint` e devolvida como
  `false` — o ecrã mostra "Falha na sincronização".

### Limitações conhecidas

1. **Sem chave estável.** Local e remoto usam `id` autoincrement independentes.
   Depois de um ciclo push/pull os `id` mudam, portanto **`goalId` em tarefas e
   transações não sobrevive à sincronização**. Por isso o `PRAGMA foreign_keys`
   está desligado — activá-lo faria o pull falhar em referências órfãs.
2. **Mirror, não merge.** Não há resolução de conflitos: o último a
   sincronizar ganha. Editar em dois dispositivos perde dados.
3. **Sem filtro por utilizador na app.** Todos entram na mesma conta Supabase
   (`AuthConfig`), logo partilham as mesmas linhas.

### Plano de evolução (quando for preciso multi-dispositivo real)

1. Adicionar coluna `uuid TEXT` (gerada no cliente, ex.: package `uuid`) às três
   tabelas → `schemaVersion = 2` + migração + `build_runner`.
2. `upsert(..., onConflict: 'uuid')` no push; casar por `uuid` no pull.
3. Guardar `updatedAt` e sincronizar só o que mudou (incremental).
4. Reativar `PRAGMA foreign_keys = ON` e mapear `goalId` por `uuid`.
5. Ecrã de login real (email/password do próprio utilizador) + RLS por `auth.uid()`.

---

## 8. Build & execução

```bash
# 1. Criar os ficheiros de config a partir dos modelos
cp lib/config/auth_config.example.dart     lib/config/auth_config.dart
cp lib/config/supabase_config.example.dart lib/config/supabase_config.dart
#    ... e preencher os valores (ou passar por --dart-define)

# 2. Dependências
flutter pub get

# 3. Geração de código Drift (sempre que mudar database.dart)
dart run build_runner build --delete-conflicting-outputs

# 4. Correr
flutter run                              # dispositivo/emulador ligado
flutter run -d linux                     # desktop, útil para testar UI rápido

# 5. Com segredos injectados em vez de ficheiro
flutter run \
  --dart-define=AUTH_EMAIL=... \
  --dart-define=AUTH_PASSWORD=... \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...

# 6. Verificações
dart analyze
flutter test

# 7. APK release
flutter build apk --release
```

---

## 9. Histórico de fases (git)

| Commit | Data | Fase |
|---|---|---|
| `c44150d` | 2026-05-26 | Initial commit |
| `ee45f5c` | 2026-05-26 | Setup: tema, estrutura de pastas, dashboard base |
| `737dd34` | 2026-05-31 | **Fase D** — sync Supabase + splash + início das Configurações |
| `78a26eb` | 2026-05-31 | Remover credenciais do versionamento, atualizar `.gitignore` |
| `1592edc` | 2026-05-31 | **Fase E** — Configurações completas (tema, moeda, backup, notificações) |
| `b46f39f` | 2026-05-31 | **Fase G** — filtros de transações (tipo e categoria) |
| `4b08838` | 2026-05-31 | Correcção de erros e avisos de depreciação |
| *(local)* | 2026-09 | **Manutenção** — segurança, sync robusta, feedback de erros, confirmações, filtros mês/ano. Ver `docs/CORRECOES.md` |
| *(local)* | 2026-09 | **Objectivos v1** — importância + prazo, lembretes agendados. Ver §10 e `docs/CORRECOES.md` |
| *(local)* | 2026-09 | **Objectivos v2** — arquivo automático de concluídos + relatórios mensais em PDF. Ver §12 e `docs/CORRECOES.md` |
| `637404a` | 2026-09 | **Identidade visual** (wordmark Familjen, fonte Hanken, paleta `#2F6BED`, splash animado) + **frontend dos Objectivos** (cartões, agrupamento por prazo, ponto de prazo) |
| `a5210b3` | 2026-09 | **Seleção múltipla** de objectivos para eliminar em lote |
| `43ba960` | 2026-09 | **Progresso automático** dos objectivos a partir das tarefas ligadas. Ver §12 |

---

## 10. Lembretes de objectivos (`goal_reminder_service.dart`)

### Regras

| Importância | Lembretes/semana | Dias (09:00 local) |
|---|---|---|
| Baixa | 1 | Qua |
| Média | 2 | Ter, Sex |
| Alta | 3 | Seg, Qua, Sex |
| Crítica | 4 | Seg, Qua, Sex, Dom |

- **+ 1 notificação garantida** no dia da data-alvo, qualquer que seja a importância.
- Só há lembretes enquanto o objectivo **não está completo** e **tem data-alvo**.
- Agenda-se apenas uma **janela de 90 dias**; objectivos de longo prazo são
  reagendados sempre que a app abre (`rescheduleAll` no `HomeScreen.initState`).

### Ciclo de vida

| Evento | Acção |
|---|---|
| Criar/editar objectivo (`add_goal_screen`) | `GoalReminderService.rescheduleAll(ref)` |
| Eliminar objectivo (`goals_screen`) | `GoalReminderService.cancelForGoal(id)` |
| Criar/editar/concluir/eliminar tarefa | `GoalProgressService.recompute(goalId)` → (se mudou) reagenda esse objectivo |
| Abertura da app (`home_screen`) | `recomputeAll` + `sweep` + `rescheduleAll` — realinha tudo com a BD |

### Esquema de IDs de notificação

`baseId(goalId) = 100000 + goalId * 100`. Slots `0..98` = lembretes
periódicos; slot `99` = notificação da data-alvo. `cancelForGoal` limpa o
intervalo `[base, base+99]`.

### Plataforma

- **Android:** usa `zonedSchedule` em modo **inexacto**
  (`inexactAllowWhileIdle`) — não precisa da permissão `SCHEDULE_EXACT_ALARM`.
  O `AndroidManifest.xml` declara `RECEIVE_BOOT_COMPLETED` e os receivers
  `ScheduledNotificationReceiver` / `ScheduledNotificationBootReceiver` para as
  notificações sobreviverem a reinícios.
- **Linux/desktop/web:** `zonedSchedule` não existe → `scheduleAt` apanha o
  erro e ignora. A app funciona, apenas sem lembretes agendados.
- Fuso horário fixado em `Africa/Maputo` (CAT, UTC+2, sem horário de verão).

### Limitações

- O texto do lembrete traz o progresso do **momento em que foi agendado** —
  não é actualizado. `rescheduleAll` no arranque corrige isto na prática.
- Sem detecção automática de fuso: se o telemóvel estiver noutro fuso, as
  09:00 são as de Maputo.

---

## 12. Arquivo de objectivos e relatórios mensais

### Progresso automático a partir das tarefas

- Se um objectivo tem **tarefas ligadas** (`Tasks.goalId`), o progresso deixa
  de ser manual: `progressPercentage = concluídas ÷ totais` (arredondado).
- `GoalProgressService.recompute(goalId)` corre sempre que uma tarefa desse
  objectivo é criada/editada/concluída/eliminada; `recomputeAll()` no arranque.
- Sem tarefas ligadas, o slider manual de `add_goal_screen` continua a valer.
- O progresso automático encadeia com o arquivo: 100% → arquiva.

### Arquivo automático

- Quando `progressPercentage >= 100`, o objectivo é **arquivado**:
  `isCompleted = true`, `archivedAt = agora`, e os lembretes são cancelados.
- Se o progresso for editado para baixo de 100, o objectivo **desarquiva**.
- `GoalArchiveService.sweep()` corre no arranque da app e depois de guardar um
  objectivo. Nada é apagado automaticamente.
- A lista principal (`goalsProvider`) só mostra activos; os arquivados estão em
  **Objectivos → menu → Objectivos arquivados**.

### Relatórios mensais (só Objectivos, por agora)

- **Conteúdo:** objectivos concluídos nesse mês + objectivos activos com
  progresso (no momento da geração) + contagens e progresso médio.
- **Geração:** `ReportService.ensureMonthlyReports()` no arranque gera todos os
  meses em falta, do mês do objectivo mais antigo até ao **mês anterior**
  (nunca o mês corrente). Um mês sem actividade não gera relatório.
- **Histórico:** tabela `Reports` (local). Ecrã em
  **Objectivos → menu → Relatórios mensais**.
- **PDF:** `ReportPdf.open()` gera e abre o diálogo do sistema
  (ver / imprimir / partilhar). Layout: cabeçalho, cartões de resumo, tabela de
  concluídos, barras de progresso dos activos.
- **Retenção:** relatórios com mais de 12 meses. No arranque, se existirem, a
  app **pergunta** antes de apagar (`_perguntarRetencao` no `HomeScreen`).
- **Plataforma:** `printing` (exportar PDF) só funciona a sério em Android; no
  desktop o diálogo pode não abrir.

### Evolução

- Adicionar relatório **financeiro** e de **tarefas** (mesma tabela `Reports`,
  novos campos no `dataJson`).
- Gráficos mais ricos no PDF (evolução do progresso ao longo do mês).

---

## 13. Convenções

- Idioma: **português europeu** em UI, comentários e nomes de domínio (`objectivo`, `receita`).
- Código gerado (`*.g.dart`) nunca é editado à mão.
- Mutações de BD passam sempre por um provider Riverpod, nunca por `AppDatabase` directo na UI.
- Toda a acção destrutiva (eliminar, restaurar backup) pede confirmação.
- Ficheiros em `config/` com segredos reais **nunca** são versionados.
