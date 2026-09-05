import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_providers.dart';
import '../services/goal_reminder_service.dart';
import '../widgets/confirm_dialog.dart';
import 'add_goal_screen.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Objectivos')),
      body: goalsAsync.when(
        data: (goals) => ListView.builder(
          itemCount: goals.length,
          itemBuilder: (_, i) {
            final goal = goals[i];
            return ListTile(
              title: Text(goal.title),
              subtitle: Text(
                '${goal.progressPercentage}% · ${goal.category} · ${goal.importance} · ${goal.term}',
              ),
              trailing: goal.isCompleted
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                // Navegar para EDITAR o objectivo
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddGoalScreen(goal: goal),
                  ),
                );
              },
              onLongPress: () async {
                if (await confirmarEliminacao(context, goal.title)) {
                  await ref.read(deleteGoalProvider(goal.id).future);
                  await GoalReminderService.cancelForGoal(goal.id);
                }
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para CRIAR um novo objectivo (formulário vazio)
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddGoalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}