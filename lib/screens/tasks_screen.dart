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
import '../widgets/confirm_dialog.dart';
import 'add_task_screen.dart';

// ----- Cor por prioridade -----
Color priorityColor(String p) {
  switch (p) {
    case 'Alta':
      return const Color(0xFFE5484D);
    case 'Baixa':
      return const Color(0xFF607D8B);
    case 'Média':
    default:
      return const Color(0xFF2F6BED);
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
    return DueInfo('Atrasadas', 'atrasada ${-dias} d', const Color(0xFFE5484D), true);
  }
  if (dias == 0) return const DueInfo('Hoje', 'hoje', Color(0xFFE5484D), false);
  if (dias == 1) return const DueInfo('Esta semana', 'amanhã', Color(0xFFF57C00), false);
  if (dias <= 7) {
    return DueInfo('Esta semana', 'em $dias d', const Color(0xFFF57C00), false);
  }
  return DueInfo('Depois', 'em $dias d', const Color(0xFF388E3C), false);
}

const _grupoOrdem = ['Atrasadas', 'Hoje', 'Esta semana', 'Depois', 'Sem data'];

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _showFilters = false;

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
      await TaskReminderService.rescheduleForTask(u);
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
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      ref.read(taskSelectionProvider.notifier).clear(),
                ),
                title: Text('${selected.length} selecionada'
                    '${selected.length == 1 ? '' : 's'}'),
                actions: [
                  IconButton(
                    tooltip: 'Concluir',
                    icon: const Icon(Icons.done_all),
                    onPressed: () => _bulkComplete(
                        {...selected}, tasksAsync.valueOrNull ?? const []),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _bulkDelete(
                        {...selected}, tasksAsync.valueOrNull ?? const []),
                  ),
                ],
              )
            : AppBar(
                title: const Text('Tarefas'),
                actions: [
                  IconButton(
                    icon: Icon(filter.active
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined),
                    onPressed: () =>
                        setState(() => _showFilters = !_showFilters),
                  ),
                ],
              ),
        body: Column(
          children: [
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
                    return true;
                  }).toList();

                  if (list.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Nada por aqui. Toca em + para criar.'),
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
        floatingActionButton: selecting
            ? null
            : FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                ),
                child: const Icon(Icons.add),
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
    await TaskReminderService.rescheduleForTask(u);
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
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: cor),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: selecting
                    ? IconButton(
                        icon: Icon(
                          selected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: selected ? scheme.primary : scheme.outline,
                        ),
                        onPressed: () => _toggleSel(ref),
                      )
                    : Checkbox(
                        value: done,
                        onChanged: (v) => _setCompleted(ref, v ?? false),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                          color: done ? scheme.onSurfaceVariant : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _Pill(text: task.priority, color: cor),
                          if (!done) ...[
                            const SizedBox(width: 6),
                            Text(
                              due.texto,
                              style: TextStyle(
                                fontSize: 12,
                                color: due.atrasada
                                    ? const Color(0xFFE5484D)
                                    : scheme.onSurfaceVariant,
                                fontWeight: due.atrasada
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                          if (goalName != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flag_outlined,
                                      size: 12,
                                      color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      goalName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: scheme.onSurfaceVariant),
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
      background: _swipeBg(Alignment.centerLeft),
      secondaryBackground: _swipeBg(Alignment.centerRight),
      confirmDismiss: (_) => confirmarEliminacao(context, task.title),
      onDismissed: (_) => _delete(ref),
      child: card,
    );
  }

  Widget _swipeBg(Alignment a) => Container(
        color: Colors.red,
        alignment: a,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      );
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold)),
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

    final totalDias = HabitService.totalDias(task);
    final feitos = checkins.length;
    final pct = totalDias <= 0 ? 0 : ((feitos / totalDias) * 100).round();
    final hoje = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final feitoHoje = checkins.any((c) =>
        c.date.year == hoje.year &&
        c.date.month == hoje.month &&
        c.date.day == hoje.day);

    final card = Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: cor),
              if (selecting)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    icon: Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
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
                          Icon(Icons.repeat, size: 14, color: cor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
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
                      const SizedBox(height: 3),
                      Text(
                        task.habitClosed
                            ? 'Terminado · $feitos de $totalDias dias'
                            : '${task.habitStartDate?.day}/${task.habitStartDate?.month} → '
                                '${task.habitEndDate?.day}/${task.habitEndDate?.month}'
                                '  ·  $feitos de $totalDias dias'
                                '${goalName != null ? '  ·  $goalName' : ''}',
                        style: TextStyle(
                            fontSize: 12, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 8,
                                backgroundColor: scheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    pct >= 100 ? const Color(0xFF388E3C) : cor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$pct%',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (!task.habitClosed && !selecting) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => HabitService.alternarHoje(ref, task),
                            icon: Icon(feitoHoje
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked),
                            label: Text(
                                feitoHoje ? 'Feito hoje' : 'Marcar hoje'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: feitoHoje
                                  ? const Color(0xFF388E3C)
                                  : scheme.primary,
                              side: BorderSide(
                                color: feitoHoje
                                    ? const Color(0xFF388E3C)
                                    : scheme.primary,
                              ),
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
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => confirmarEliminacao(context, task.title),
      onDismissed: (_) => _delete(ref),
      child: card,
    );
  }
}
