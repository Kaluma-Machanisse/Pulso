import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_providers.dart';
import '../services/goal_reminder_service.dart';
import '../widgets/confirm_dialog.dart';
import 'add_goal_screen.dart';

class ArchivedGoalsScreen extends ConsumerWidget {
  const ArchivedGoalsScreen({super.key});

  String _data(DateTime? d) =>
      d == null ? '' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Objectivos arquivados')),
      body: archivedAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(
              child: Text('Nada arquivado.\nOs objectivos a 100% vêm para aqui.',
                  textAlign: TextAlign.center),
            );
          }
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (_, i) {
              final goal = goals[i];
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(goal.title),
                subtitle: Text(
                    '${goal.category} · concluído em ${_data(goal.archivedAt)}'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddGoalScreen(goal: goal),
                  ),
                ),
                onLongPress: () async {
                  if (await confirmarEliminacao(context, goal.title)) {
                    await ref.read(deleteGoalProvider(goal.id).future);
                    await GoalReminderService.cancelForGoal(goal.id);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
