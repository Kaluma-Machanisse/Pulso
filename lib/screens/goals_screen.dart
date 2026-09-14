import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/goal_providers.dart';
import '../providers/goal_selection_provider.dart';
import '../services/goal_reminder_service.dart';
import '../services/goal_archive_service.dart';
import '../providers/database_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../services/report_service.dart';
import '../theme/pulso_theme.dart';
import '../theme/semantic_colors.dart';
import 'add_goal_screen.dart';
import 'archived_goals_screen.dart';

// ----- Cores por nível de importância -----
Color importanceColor(String importance) {
  switch (importance) {
    case 'Baixa':
      return PulsoColors.textMutedLight;
    case 'Alta':
      return const Color(0xFFF57C00); // laranja — mesma escala de urgência
    case 'Crítica':
      return PulsoColors.danger;
    case 'Média':
    default:
      return PulsoColors.primaryLight;
  }
}

// ----- Dias que faltam e cor do ponto de prazo -----
class DeadlineStatus {
  final String texto;
  final Color cor;
  final bool atrasado;
  const DeadlineStatus(this.texto, this.cor, this.atrasado);
}

DeadlineStatus deadlineInfo(DateTime? target) {
  if (target == null) {
    return const DeadlineStatus('sem data-alvo', Color(0xFF9E9E9E), false);
  }
  final hoje = DateTime.now();
  final t = DateTime(target.year, target.month, target.day);
  final h = DateTime(hoje.year, hoje.month, hoje.day);
  final dias = t.difference(h).inDays;

  if (dias < 0) {
    return DeadlineStatus('atrasado ${-dias} d', PulsoColors.danger, true);
  }
  if (dias == 0) {
    return DeadlineStatus('é hoje', PulsoColors.danger, false);
  }
  if (dias <= 7) {
    return DeadlineStatus('faltam $dias d', const Color(0xFFF57C00), false);
  }
  if (dias <= 30) {
    return DeadlineStatus('faltam $dias d', const Color(0xFFFBC02D), false);
  }
  return DeadlineStatus('faltam $dias d', SemanticColors.receita, false);
}

Future<void> _eliminarObjectivo(WidgetRef ref, int id) async {
  await ref.read(deleteGoalProvider(id).future);
  try {
    await GoalReminderService.cancelForGoal(id);
  } catch (_) {}
}

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  Future<void> _eliminarSelecionados(
      BuildContext context, WidgetRef ref, Set<int> ids) async {
    final n = ids.length;
    final ok = await confirmarEliminacao(
        context, n == 1 ? '1 objectivo' : '$n objectivos');
    if (!ok) return;
    for (final id in ids) {
      await _eliminarObjectivo(ref, id);
    }
    ref.read(goalSelectionProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final selected = ref.watch(goalSelectionProvider);
    final selecting = selected.isNotEmpty;

    final allIds = goalsAsync.maybeWhen(
      data: (g) => g.map((e) => e.id).toSet(),
      orElse: () => <int>{},
    );

    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(goalSelectionProvider.notifier).clear();
      },
      child: Scaffold(
        appBar: selecting
            ? AppBar(
                leading: IconButton(
                  tooltip: 'Cancelar seleção',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () =>
                      ref.read(goalSelectionProvider.notifier).clear(),
                ),
                title: Text('${selected.length} selecionado'
                    '${selected.length == 1 ? '' : 's'}'),
                actions: [
                  IconButton(
                    tooltip: 'Selecionar todos',
                    icon: const Icon(Icons.select_all_rounded),
                    onPressed: () => ref
                        .read(goalSelectionProvider.notifier)
                        .selectAll(allIds),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () =>
                        _eliminarSelecionados(context, ref, {...selected}),
                  ),
                ],
              )
            : AppBar(
                title: const Text('Objectivos'),
                actions: [
                  IconButton(
                    tooltip: 'Objectivos arquivados',
                    icon: const Icon(Icons.archive_rounded),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ArchivedGoalsScreen())),
                  ),
                  IconButton(
                    tooltip: 'Gerar relatório deste mês',
                    icon: const Icon(Icons.summarize_rounded),
                    onPressed: () async {
                      await ReportService.generateNowForCurrentMonth(ref);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Relatório gerado. Vê em Estatísticas.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
        body: goalsAsync.when(
          data: (goals) {
            if (goals.isEmpty) return const _EmptyState();

            int ordenar(Goal a, Goal b) {
              final da = a.targetDate ?? DateTime(9999);
              final db = b.targetDate ?? DateTime(9999);
              return da.compareTo(db);
            }

            final curto = goals.where((g) => g.term == 'Curto prazo').toList()
              ..sort(ordenar);
            final medio = goals.where((g) => g.term == 'Médio prazo').toList()
              ..sort(ordenar);
            final longo = goals.where((g) => g.term == 'Longo prazo').toList()
              ..sort(ordenar);

            _GoalCard card(Goal g) => _GoalCard(
                  goal: g,
                  selecting: selecting,
                  selected: selected.contains(g.id),
                );

            return ListView(
              padding: const EdgeInsets.only(bottom: 88, top: 4),
              children: [
                if (curto.isNotEmpty) ...[
                  const _SectionHeader('Curto prazo'),
                  ...curto.map(card),
                ],
                if (medio.isNotEmpty) ...[
                  const _SectionHeader('Médio prazo'),
                  ...medio.map(card),
                ],
                if (longo.isNotEmpty) ...[
                  const _SectionHeader('Longo prazo'),
                  ...longo.map(card),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
        ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final p = PulsoPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_rounded, size: 56, color: p.textMuted),
            const SizedBox(height: 16),
            Text('Ainda não tens objectivos.', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Define uma meta de curto, médio ou longo prazo e liga-a a tarefas.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddGoalScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar objectivo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final Goal goal;
  final bool selecting;
  final bool selected;

  const _GoalCard({
    required this.goal,
    this.selecting = false,
    this.selected = false,
  });

  Future<void> _concluir(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Concluir objectivo?'),
        content: Text(
            '"${goal.title}" fica a 100% e é arquivado (não é apagado).'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Concluir')),
        ],
      ),
    );
    if (ok != true) return;

    final db = ref.read(databaseProvider);
    await db.update(db.goals).replace(
          goal.copyWith(progressPercentage: 100, isCompleted: true),
        );
    await GoalArchiveService.sweep(ref);
    await GoalReminderService.rescheduleAll(ref);
  }

  void _toggle(WidgetRef ref) =>
      ref.read(goalSelectionProvider.notifier).toggle(goal.id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final cor = importanceColor(goal.importance);
    final prazo = deadlineInfo(goal.targetDate);
    final progresso = goal.progressPercentage.clamp(0, 100);

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
            _toggle(ref);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddGoalScreen(goal: goal)),
            );
          }
        },
        onLongPress: selecting ? null : () => _toggle(ref),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: cor, width: 5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (selecting)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_rounded,
                                size: 20,
                                color: selected
                                    ? scheme.primary
                                    : scheme.outline,
                              ),
                            )
                          else
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: prazo.cor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              goal.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _Chip(text: goal.importance, color: cor),
                          if (!selecting)
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              onSelected: (v) async {
                                if (v == 'editar') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          AddGoalScreen(goal: goal)));
                                } else if (v == 'concluir') {
                                  await _concluir(context, ref);
                                } else if (v == 'selecionar') {
                                  _toggle(ref);
                                } else if (v == 'eliminar') {
                                  if (await confirmarEliminacao(
                                      context, goal.title)) {
                                    await _eliminarObjectivo(ref, goal.id);
                                  }
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'editar', child: Text('Editar')),
                                PopupMenuItem(
                                    value: 'concluir',
                                    child: Text('Marcar como concluído')),
                                PopupMenuItem(
                                    value: 'selecionar',
                                    child: Text('Selecionar')),
                                PopupMenuItem(
                                    value: 'eliminar',
                                    child: Text('Eliminar')),
                              ],
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18, right: 8),
                        child: Text(
                          '${goal.category}  ·  ${prazo.texto}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: prazo.atrasado
                                    ? scheme.error
                                    : scheme.onSurfaceVariant,
                                fontWeight: prazo.atrasado
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 18, right: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progresso / 100,
                                  minHeight: 8,
                                  backgroundColor: scheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      progresso >= 100
                                          ? SemanticColors.receita
                                          : cor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('$progresso%',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            if (!selecting)
                              TextButton(
                                onPressed: () => _concluir(context, ref),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 32),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                ),
                                child: const Text('Concluir'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Sem swipe durante a seleção múltipla (evita conflito de gestos).
    if (selecting) return card;

    return Dismissible(
      key: ValueKey(goal.id),
      direction: DismissDirection.horizontal,
      background: _swipeBg(context, Alignment.centerLeft),
      secondaryBackground: _swipeBg(context, Alignment.centerRight),
      confirmDismiss: (_) => confirmarEliminacao(context, goal.title),
      onDismissed: (_) => _eliminarObjectivo(ref, goal.id),
      child: card,
    );
  }

  Widget _swipeBg(BuildContext context, Alignment alignment) => Container(
        color: Theme.of(context).colorScheme.error,
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: PulsoSpace.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: PulsoSpace.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PulsoRadius.sm),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
