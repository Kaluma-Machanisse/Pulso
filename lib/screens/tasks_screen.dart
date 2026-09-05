import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../providers/goal_providers.dart';
import '../services/goal_progress_service.dart';
import '../widgets/confirm_dialog.dart';
import 'add_task_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final goals = ref.watch(goalsProvider).valueOrNull ?? const [];
    final goalName = {for (final g in goals) g.id: g.title};

    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('Sem tarefas. Toca em + para criar.'));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, i) {
              final task = tasks[i];
              final objectivo =
                  task.goalId != null ? goalName[task.goalId] : null;
              return ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (v) async {
                    await ref.read(updateTaskProvider(
                            task.copyWith(isCompleted: v ?? false))
                        .future);
                    await GoalProgressService.recompute(ref, task.goalId);
                  },
                ),
                title: Text(
                  task.title,
                  style: task.isCompleted
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        )
                      : null,
                ),
                subtitle: Text(
                  objectivo != null
                      ? '${task.priority}  ·  $objectivo'
                      : task.priority,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
                ),
                onLongPress: () async {
                  if (await confirmarEliminacao(context, task.title)) {
                    await ref.read(deleteTaskProvider(task.id).future);
                    await GoalProgressService.recompute(ref, task.goalId);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
