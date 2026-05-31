import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import 'database_provider.dart';   // reutiliza o databaseProvider que já existe

// Todas as tarefas (stream reativa)
final tasksProvider = StreamProvider<List<Task>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.tasks).watch();
});

// Adicionar tarefa
final addTaskProvider = FutureProvider.family<void, TasksCompanion>((ref, task) async {
  final db = ref.read(databaseProvider);
  await db.into(db.tasks).insert(task);
});

// Atualizar tarefa
final updateTaskProvider = FutureProvider.family<void, Task>((ref, task) async {
  final db = ref.read(databaseProvider);
  await db.update(db.tasks).replace(task);
});

// Eliminar tarefa
final deleteTaskProvider = FutureProvider.family<void, int>((ref, id) async {
  final db = ref.read(databaseProvider);
  await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
});

// Filtrar tarefas por objetivo (será útil em breve)
final tasksByGoalProvider = StreamProvider.family<List<Task>, int>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.tasks)..where((t) => t.goalId.equals(goalId))).watch();
});