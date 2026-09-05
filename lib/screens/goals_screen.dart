import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/goal_providers.dart';
import '../services/goal_reminder_service.dart';
import '../widgets/confirm_dialog.dart';
import 'add_goal_screen.dart';
import 'archived_goals_screen.dart';
import 'reports_screen.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  void _editar(BuildContext context, Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddGoalScreen(goal: goal)),
    );
  }

  Future<void> _eliminar(WidgetRef ref, Goal goal) async {
    await ref.read(deleteGoalProvider(goal.id).future);
    await GoalReminderService.cancelForGoal(goal.id);
  }

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
                value: 'arquivados',
                child: Text('Objectivos arquivados'),
              ),
              PopupMenuItem(
                value: 'relatorios',
                child: Text('Relatórios mensais'),
              ),
            ],
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(
                child: Text('Sem objectivos. Toca em + para criar.'));
          }
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (_, i) {
              final goal = goals[i];
              return Dismissible(
                key: ValueKey(goal.id),
                direction: DismissDirection.horizontal,
                background: _swipeBg(Alignment.centerLeft),
                secondaryBackground: _swipeBg(Alignment.centerRight),
                confirmDismiss: (_) =>
                    confirmarEliminacao(context, goal.title),
                onDismissed: (_) => _eliminar(ref, goal),
                child: ListTile(
                  title: Text(goal.title),
                  subtitle: Text(
                    '${goal.progressPercentage}% · ${goal.category} · ${goal.importance} · ${goal.term}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'editar') {
                        _editar(context, goal);
                      } else if (value == 'eliminar') {
                        if (await confirmarEliminacao(context, goal.title)) {
                          await _eliminar(ref, goal);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(
                          value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                  onTap: () => _editar(context, goal),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddGoalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _swipeBg(Alignment alignment) {
    return Container(
      color: Colors.red,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
