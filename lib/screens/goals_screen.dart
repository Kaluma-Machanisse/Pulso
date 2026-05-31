import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';                // <-- adiciona esta linha
import '../providers/goal_providers.dart';
import '../database/database.dart';

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
              subtitle: Text('${goal.progressPercentage}% - ${goal.category}'),
              trailing: goal.isCompleted
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onLongPress: () {
                ref.read(deleteGoalProvider(goal.id));
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newGoal = GoalsCompanion.insert(
            title: 'Novo objectivo ${DateTime.now().millisecond}',
            category: const Value('Saúde'),
            targetDate: Value(DateTime.now().add(const Duration(days: 30))),
          );
          ref.read(addGoalProvider(newGoal));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}