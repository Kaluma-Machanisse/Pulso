import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/goal_providers.dart';
import '../services/goal_reminder_service.dart';
import '../services/goal_archive_service.dart';
import '../providers/database_provider.dart';
import '../widgets/confirm_dialog.dart';
import 'add_goal_screen.dart';
import 'archived_goals_screen.dart';
import 'reports_screen.dart';

// ----- Cores por nível de importância -----
Color importanceColor(String importance) {
  switch (importance) {
    case 'Baixa':
      return const Color(0xFF607D8B); // blue grey
    case 'Alta':
      return const Color(0xFFF57C00); // orange
    case 'Crítica':
      return const Color(0xFFD32F2F); // red
    case 'Média':
    default:
      return const Color(0xFF1976D2); // blue
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
    return DeadlineStatus('atrasado ${-dias} d', const Color(0xFFD32F2F), true);
  }
  if (dias == 0) {
    return const DeadlineStatus('é hoje', Color(0xFFD32F2F), false);
  }
  if (dias <= 7) {
    return DeadlineStatus('faltam $dias d', const Color(0xFFF57C00), false);
  }
  if (dias <= 30) {
    return DeadlineStatus('faltam $dias d', const Color(0xFFFBC02D), false);
  }
  return DeadlineStatus('faltam $dias d', const Color(0xFF388E3C), false);
}

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectivos'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              final page = value == 'arquivados'
                  ? const ArchivedGoalsScreen()
                  : const ReportsScreen();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => page));
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'arquivados', child: Text('Objectivos arquivados')),
              PopupMenuItem(
                  value: 'relatorios', child: Text('Relatórios mensais')),
            ],
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const _EmptyState();
          }
          // Agrupar por prazo, cada grupo ordenado pela data-alvo mais próxima.
          int ordenar(Goal a, Goal b) {
            final da = a.targetDate ?? DateTime(9999);
            final db = b.targetDate ?? DateTime(9999);
            return da.compareTo(db);
          }

          final curto = goals.where((g) => g.term == 'Curto prazo').toList()
            ..sort(ordenar);
          final longo = goals.where((g) => g.term == 'Longo prazo').toList()
            ..sort(ordenar);

          return ListView(
            padding: const EdgeInsets.only(bottom: 88, top: 4),
            children: [
              if (curto.isNotEmpty) ...[
                const _SectionHeader('Curto prazo'),
                ...curto.map((g) => _GoalCard(goal: g)),
              ],
              if (longo.isNotEmpty) ...[
                const _SectionHeader('Longo prazo'),
                ...longo.map((g) => _GoalCard(goal: g)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddGoalScreen()),
        ),
        child: const Icon(Icons.add),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Ainda não tens objectivos.',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Toca em + para criar o primeiro.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

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

  Future<void> _eliminar(WidgetRef ref) async {
    await ref.read(deleteGoalProvider(goal.id).future);
    await GoalReminderService.cancelForGoal(goal.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cor = importanceColor(goal.importance);
    final prazo = deadlineInfo(goal.targetDate);
    final progresso = goal.progressPercentage.clamp(0, 100);

    return Dismissible(
      key: ValueKey(goal.id),
      direction: DismissDirection.horizontal,
      background: _swipeBg(Alignment.centerLeft),
      secondaryBackground: _swipeBg(Alignment.centerRight),
      confirmDismiss: (_) => confirmarEliminacao(context, goal.title),
      onDismissed: (_) => _eliminar(ref),
      child: Card(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddGoalScreen(goal: goal)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: cor), // faixa de importância
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // ponto de prazo
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _Chip(text: goal.importance, color: cor),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              onSelected: (v) async {
                                if (v == 'editar') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          AddGoalScreen(goal: goal)));
                                } else if (v == 'concluir') {
                                  await _concluir(context, ref);
                                } else if (v == 'eliminar') {
                                  if (await confirmarEliminacao(
                                      context, goal.title)) {
                                    await _eliminar(ref);
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
                            style: TextStyle(
                              fontSize: 12,
                              color: prazo.atrasado
                                  ? const Color(0xFFD32F2F)
                                  : Colors.grey.shade600,
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
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        progresso >= 100
                                            ? const Color(0xFF388E3C)
                                            : cor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('$progresso%',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _swipeBg(Alignment alignment) => Container(
        color: Colors.red,
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
