import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/task_providers.dart';
import '../providers/goal_providers.dart';
import '../providers/task_filter_provider.dart';
import '../providers/task_selection_provider.dart';
import '../services/goal_progress_service.dart';
import '../services/task_reminder_service.dart';
import '../services/habit_service.dart';
import '../theme/pulso_theme.dart';
import '../theme/semantic_colors.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/habit_heatmap.dart';
import 'add_task_screen.dart';

const _corMedia = Color(0xFF9C6BE0); // roxo — distinto do azul de marca
const _corAlerta = Color(0xFFF57C00); // mesma laranja usada em Objectivos/Estatísticas

// ----- Cor por prioridade -----
Color priorityColor(String p) {
  switch (p) {
    case 'Alta':
      return PulsoColors.danger;
    case 'Baixa':
      return PulsoColors.textMutedLight;
    case 'Média':
    default:
      return _corMedia;
  }
}

// ----- Vencimento -----
class DueInfo {
  final String grupo; // "Atrasadas" | "Hoje" | "Esta semana" | "Depois" | "Sem data"
  final String texto;
  final Color cor;
  final bool atrasada;
  const DueInfo(this.grupo, this.texto, this.cor, this.atrasada);
}

DueInfo dueInfo(DateTime? due) {
  if (due == null) {
    return const DueInfo('Sem data', 'sem data', Color(0xFF9E9E9E), false);
  }
  final now = DateTime.now();
  final t = DateTime(due.year, due.month, due.day);
  final h = DateTime(now.year, now.month, now.day);
  final dias = t.difference(h).inDays;
  if (dias < 0) {
    return DueInfo('Atrasadas', 'atrasada ${-dias} d', PulsoColors.danger, true);
  }
  if (dias == 0) return DueInfo('Hoje', 'hoje', PulsoColors.danger, false);
  if (dias == 1) return const DueInfo('Esta semana', 'amanhã', _corAlerta, false);
  if (dias <= 7) {
    return DueInfo('Esta semana', 'em $dias d', _corAlerta, false);
  }
  return DueInfo('Depois', 'em $dias d', SemanticColors.receita, false);
}

const _grupoOrdem = ['Atrasadas', 'Hoje', 'Esta semana', 'Depois', 'Sem data'];

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _showFilters = false;
  final _searchCtrl = TextEditingController();
  String _pesquisa = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _recompute(Iterable<int?> goalIds) async {
    for (final id in goalIds.whereType<int>().toSet()) {
      await GoalProgressService.recompute(ref, id);
    }
  }

  Future<void> _bulkDelete(Set<int> ids, List<Task> all) async {
    final ok = await confirmarEliminacao(
        context, ids.length == 1 ? '1 tarefa' : '${ids.length} tarefas');
    if (!ok) return;
    final affectedGoals = all.where((t) => ids.contains(t.id)).map((t) => t.goalId);
    for (final id in ids) {
      await ref.read(deleteTaskProvider(id).future);
      await TaskReminderService.cancelForTask(id);
    }
    await _recompute(affectedGoals);
    ref.read(taskSelectionProvider.notifier).clear();
  }

  Future<void> _bulkComplete(Set<int> ids, List<Task> all) async {
    final alvo = all.where((t) => ids.contains(t.id) && !t.isCompleted);
    for (final t in alvo) {
      final u = t.copyWith(isCompleted: true);
      await ref.read(updateTaskProvider(u).future);
      await TaskReminderService.rescheduleForTask(ref, u);
    }
    await _recompute(alvo.map((t) => t.goalId));
    ref.read(taskSelectionProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final selected = ref.watch(taskSelectionProvider);
    final selecting = selected.isNotEmpty;
    final goals = ref.watch(goalsProvider).valueOrNull ?? const <Goal>[];
    final goalName = {for (final g in goals) g.id: g.title};

    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(taskSelectionProvider.notifier).clear();
      },
      child: Scaffold(
        appBar: selecting
            ? AppBar(
                leading: IconButton(
                  tooltip: 'Cancelar seleção',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () =>
                      ref.read(taskSelectionProvider.notifier).clear(),
                ),
                title: Text('${selected.length} selecionada'
                    '${selected.length == 1 ? '' : 's'}'),
                actions: [
                  IconButton(
                    tooltip: 'Concluir',
                    icon: const Icon(Icons.done_all_rounded),
                    onPressed: () => _bulkComplete(
                        {...selected}, tasksAsync.valueOrNull ?? const []),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _bulkDelete(
                        {...selected}, tasksAsync.valueOrNull ?? const []),
                  ),
                ],
              )
            : AppBar(
                title: const Text('Tarefas'),
                actions: [
                  IconButton(
                    tooltip: filter.showCompleted
                        ? 'Esconder concluídas'
                        : 'Mostrar concluídas',
                    icon: Icon(filter.showCompleted
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded),
                    onPressed: () => ref
                        .read(taskFilterProvider.notifier)
                        .toggleCompleted(!filter.showCompleted),
                  ),
                  IconButton(
                    tooltip: 'Filtros',
                    icon: Icon(
                      Icons.filter_alt_rounded,
                      color: filter.active
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () =>
                        setState(() => _showFilters = !_showFilters),
                  ),
                ],
              ),
        body: Column(
          children: [
            if (!selecting)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _pesquisa = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar tarefa',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _pesquisa.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _pesquisa = '');
                            },
                          ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PulsoRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            if (_showFilters && !selecting)
              _FilterPanel(goals: goals),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  final list = tasks.where((t) {
                    if (filter.priority != 'todas' &&
                        t.priority != filter.priority) {
                      return false;
                    }
                    if (filter.goalId != null && t.goalId != filter.goalId) {
                      return false;
                    }
                    if (!filter.showCompleted && t.isCompleted) return false;
                    if (_pesquisa.isNotEmpty &&
                        !t.title.toLowerCase().contains(_pesquisa)) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (list.isEmpty) {
                    final p = PulsoPalette.of(context);
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.checklist_rounded,
                                size: 56, color: p.textMuted),
                            const SizedBox(height: 16),
                            Text('Nada por aqui.',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'Cria a tua primeira tarefa para começares a organizar o dia.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const AddTaskScreen()),
                              ),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Criar tarefa'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Hábitos activos ficam à parte (não têm data única).
                  final habitosActivos = list
                      .where((t) => t.isHabit && !t.habitClosed)
                      .toList()
                    ..sort((a, b) => (a.habitEndDate ?? DateTime(9999))
                        .compareTo(b.habitEndDate ?? DateTime(9999)));

                  // Concluídas visíveis → grupo próprio no fim (inclui
                  // hábitos já fechados).
                  final pendentes = list
                      .where((t) => !t.isHabit && !t.isCompleted)
                      .toList();
                  final concluidas =
                      list.where((t) => t.isCompleted).toList();

                  final Map<String, List<Task>> grupos = {};
                  for (final t in pendentes) {
                    grupos.putIfAbsent(dueInfo(t.dueDate).grupo, () => []).add(t);
                  }
                  for (final g in grupos.values) {
                    g.sort((a, b) => (a.dueDate ?? DateTime(9999))
                        .compareTo(b.dueDate ?? DateTime(9999)));
                  }

                  Widget cardPara(Task t) => t.isHabit
                      ? _HabitCard(
                          task: t,
                          goalName: goalName[t.goalId],
                          selecting: selecting,
                          selected: selected.contains(t.id),
                        )
                      : _TaskCard(
                          task: t,
                          goalName: goalName[t.goalId],
                          selecting: selecting,
                          selected: selected.contains(t.id),
                        );

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 88, top: 4),
                    children: [
                      if (habitosActivos.isNotEmpty) ...[
                        _SectionHeader('Hábitos'),
                        ...habitosActivos.map(cardPara),
                      ],
                      for (final nome in _grupoOrdem)
                        if (grupos[nome] != null) ...[
                          _SectionHeader(nome),
                          ...grupos[nome]!.map(cardPara),
                        ],
                      if (concluidas.isNotEmpty) ...[
                        _SectionHeader('Concluídas (${concluidas.length})'),
                        ...concluidas.map(cardPara),
                      ],
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends ConsumerWidget {
  final List<Goal> goals;
  const _FilterPanel({required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(taskFilterProvider);
    final n = ref.read(taskFilterProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: f.priority,
                  decoration: const InputDecoration(labelText: 'Prioridade'),
                  items: const ['todas', 'Alta', 'Média', 'Baixa']
                      .map((p) => DropdownMenuItem(
                          value: p, child: Text(p == 'todas' ? 'Todas' : p)))
                      .toList(),
                  onChanged: (v) => n.setPriority(v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue:
                      goals.any((g) => g.id == f.goalId) ? f.goalId : null,
                  decoration: const InputDecoration(labelText: 'Objectivo'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    for (final g in goals)
                      DropdownMenuItem(value: g.id, child: Text(g.title)),
                  ],
                  onChanged: n.setGoal,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Mostrar concluídas'),
                  value: f.showCompleted,
                  onChanged: n.toggleCompleted,
                ),
              ),
              TextButton(onPressed: n.reset, child: const Text('Limpar')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String texto;
  const _SectionHeader(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        texto.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final Task task;
  final String? goalName;
  final bool selecting;
  final bool selected;

  const _TaskCard({
    required this.task,
    this.goalName,
    this.selecting = false,
    this.selected = false,
  });

  Future<void> _setCompleted(WidgetRef ref, bool v) async {
    final u = task.copyWith(isCompleted: v);
    await ref.read(updateTaskProvider(u).future);
    await TaskReminderService.rescheduleForTask(ref, u);
    await GoalProgressService.recompute(ref, task.goalId);
  }

  Future<void> _delete(WidgetRef ref) async {
    await ref.read(deleteTaskProvider(task.id).future);
    await TaskReminderService.cancelForTask(task.id);
    await GoalProgressService.recompute(ref, task.goalId);
  }

  void _toggleSel(WidgetRef ref) =>
      ref.read(taskSelectionProvider.notifier).toggle(task.id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final cor = priorityColor(task.priority);
    final due = dueInfo(task.dueDate);
    final done = task.isCompleted;

    final card = Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PulsoRadius.md),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 1.6 : 1,
        ),
      ),
      color: selected ? scheme.primary.withValues(alpha: 0.06) : null,
      child: InkWell(
        onTap: () {
          if (selecting) {
            _toggleSel(ref);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
            );
          }
        },
        onLongPress: selecting ? null : () => _toggleSel(ref),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: cor, width: 5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: selecting
                    ? IconButton(
                        tooltip: selected ? 'Remover da seleção' : 'Selecionar',
                        icon: Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.circle_rounded,
                          color: selected ? scheme.primary : scheme.outline,
                        ),
                        onPressed: () => _toggleSel(ref),
                      )
                    : Semantics(
                        label: done
                            ? 'Marcar "${task.title}" como não concluída'
                            : 'Marcar "${task.title}" como concluída',
                        child: Checkbox(
                          value: done,
                          onChanged: (v) => _setCompleted(ref, v ?? false),
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration:
                                  done ? TextDecoration.lineThrough : null,
                              color: done ? scheme.onSurfaceVariant : null,
                            ),
                      ),
                      const SizedBox(height: PulsoSpace.xs),
                      Row(
                        children: [
                          _Pill(text: task.priority, color: cor),
                          if (!done) ...[
                            const SizedBox(width: PulsoSpace.sm),
                            Text(
                              due.texto,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: due.atrasada
                                        ? PulsoColors.danger
                                        : scheme.onSurfaceVariant,
                                    fontWeight: due.atrasada
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                          ],
                          if (goalName != null) ...[
                            const SizedBox(width: PulsoSpace.sm),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flag_rounded,
                                      size: 12,
                                      color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      goalName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (!selecting)
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'editar') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AddTaskScreen(task: task)));
                    } else if (v == 'selecionar') {
                      _toggleSel(ref);
                    } else if (v == 'eliminar') {
                      if (await confirmarEliminacao(context, task.title)) {
                        await _delete(ref);
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(
                        value: 'selecionar', child: Text('Selecionar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );

    if (selecting) return card;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      background: _swipeBg(context, Alignment.centerLeft),
      secondaryBackground: _swipeBg(context, Alignment.centerRight),
      confirmDismiss: (_) => confirmarEliminacao(context, task.title),
      onDismissed: (_) => _delete(ref),
      child: card,
    );
  }

  Widget _swipeBg(BuildContext context, Alignment a) => Container(
        color: Theme.of(context).colorScheme.error,
        alignment: a,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      );
}

/// Mini-cartão de estatística dentro do cartão de hábito (feitos/%/sequência).
/// Anel de progresso semanal com chama no centro — mostra a sequência
/// actual de dias consecutivos (até 7, reinicia visualmente por semana).
class _StreakRing extends StatelessWidget {
  final int streak;
  const _StreakRing({required this.streak});

  static const _corChama = Color(0xFFE8A13C);

  @override
  Widget build(BuildContext context) {
    final p = PulsoPalette.of(context);
    final progresso = (streak % 7 == 0 && streak > 0) ? 1.0 : (streak % 7) / 7;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progresso),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => CircularProgressIndicator(
                    value: v,
                    strokeWidth: 3.5,
                    backgroundColor: p.border,
                    valueColor: const AlwaysStoppedAnimation(_corChama),
                  ),
                ),
                Icon(Icons.local_fire_department_rounded,
                    size: 16,
                    color: streak > 0 ? _corChama : p.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Text('$streak dias',
              style: Theme.of(context).textTheme.labelSmall),
        ],
    );
  }
}

class _HabitMiniStat extends StatelessWidget {
  final String valor;
  final String label;
  final IconData? icone;
  final Color? destaque;

  const _HabitMiniStat({
    required this.valor,
    required this.label,
    this.icone,
    this.destaque,
  });

  @override
  Widget build(BuildContext context) {
    final p = PulsoPalette.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 13, color: destaque ?? p.textPrimary),
              const SizedBox(width: 2),
            ],
            Text(valor,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: destaque ?? p.textPrimary,
                    )),
          ],
        ),
        const SizedBox(height: 1),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

Widget _divisor(BuildContext context) => Container(
      width: 1,
      color: PulsoPalette.of(context).border,
    );

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: PulsoSpace.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PulsoRadius.sm),
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  final Task task;
  final String? goalName;
  final bool selecting;
  final bool selected;

  const _HabitCard({
    required this.task,
    this.goalName,
    this.selecting = false,
    this.selected = false,
  });

  void _toggleSel(WidgetRef ref) =>
      ref.read(taskSelectionProvider.notifier).toggle(task.id);

  Future<void> _delete(WidgetRef ref) async {
    await ref.read(deleteTaskProvider(task.id).future);
    await TaskReminderService.cancelForTask(task.id);
    await GoalProgressService.recompute(ref, task.goalId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final cor = priorityColor(task.priority);
    final checkinsAsync = ref.watch(habitCheckinsProvider(task.id));
    final checkins = checkinsAsync.valueOrNull ?? const [];
    final nLembretes =
        (ref.watch(habitRemindersProvider(task.id)).valueOrNull ?? const [])
            .length;

    final totalDias = HabitService.totalDias(task);
    final feitos = checkins.length;
    final pct = totalDias <= 0 ? 0 : ((feitos / totalDias) * 100).round();
    final hoje = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final feitoHoje = checkins.any((c) =>
        c.date.year == hoje.year &&
        c.date.month == hoje.month &&
        c.date.day == hoje.day);
    final streak = HabitService.streakActual(checkins.map((c) => c.date).toList());

    final card = Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PulsoRadius.md),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 1.6 : 1,
        ),
      ),
      color: selected ? scheme.primary.withValues(alpha: 0.06) : null,
      child: InkWell(
        onTap: () {
          if (selecting) {
            _toggleSel(ref);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
            );
          }
        },
        onLongPress: selecting ? null : () => _toggleSel(ref),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: cor, width: 5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selecting)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    tooltip: selected ? 'Remover da seleção' : 'Selecionar',
                    icon: Icon(
                      selected ? Icons.check_circle_rounded : Icons.circle_rounded,
                      color: selected ? scheme.primary : scheme.outline,
                    ),
                    onPressed: () => _toggleSel(ref),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.repeat_rounded, size: 14, color: cor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    decoration: task.habitClosed
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.habitClosed
                                        ? scheme.onSurfaceVariant
                                        : null,
                                  ),
                            ),
                          ),
                          _Pill(text: task.priority, color: cor),
                        ],
                      ),
                      const SizedBox(height: PulsoSpace.xs),
                      Text(
                        task.habitClosed
                            ? 'Terminado'
                            : '${task.habitStartDate?.day}/${task.habitStartDate?.month} → '
                                '${task.habitEndDate?.day}/${task.habitEndDate?.month}'
                                '  ·  $nLembretes lembrete${nLembretes == 1 ? '' : 's'}/dia'
                                '${goalName != null ? '  ·  $goalName' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: PulsoPalette.of(context).surfaceElevated,
                          borderRadius: BorderRadius.circular(PulsoRadius.sm),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                  child: _HabitMiniStat(
                                      valor: '$feitos', label: 'Feitos')),
                              _divisor(context),
                              Expanded(
                                  child: _HabitMiniStat(
                                      valor: '$pct%',
                                      label: 'Completo',
                                      destaque: pct >= 100
                                          ? SemanticColors.receita
                                          : cor)),
                              _divisor(context),
                              Expanded(
                                  child: _StreakRing(streak: streak)),
                            ],
                          ),
                        ),
                      ),
                      if (task.habitStartDate != null &&
                          task.habitEndDate != null) ...[
                        const SizedBox(height: 14),
                        HabitHeatmap(
                          start: task.habitStartDate!,
                          end: task.habitEndDate!,
                          checkins: checkins
                              .map((c) => DateTime(
                                  c.date.year, c.date.month, c.date.day))
                              .toSet(),
                        ),
                      ],
                      if (!task.habitClosed && !selecting) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () => HabitService.alternarHoje(ref, task),
                            icon: Icon(feitoHoje
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded),
                            label: Text(
                                feitoHoje ? 'Feito hoje' : 'Marcar hoje'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: feitoHoje
                                  ? SemanticColors.receita
                                  : scheme.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!selecting)
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'editar') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AddTaskScreen(task: task)));
                    } else if (v == 'selecionar') {
                      _toggleSel(ref);
                    } else if (v == 'eliminar') {
                      if (await confirmarEliminacao(context, task.title)) {
                        await _delete(ref);
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(
                        value: 'selecionar', child: Text('Selecionar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );

    if (selecting) return card;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => confirmarEliminacao(context, task.title),
      onDismissed: (_) => _delete(ref),
      child: card,
    );
  }
}
