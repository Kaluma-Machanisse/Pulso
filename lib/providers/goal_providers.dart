import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import 'database_provider.dart';   // <-- importa daqui

final goalsProvider = StreamProvider<List<Goal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.goals).watch();
});

final addGoalProvider = FutureProvider.family<void, GoalsCompanion>((ref, goal) async {
  final db = ref.read(databaseProvider);
  await db.into(db.goals).insert(goal);
});

final updateGoalProvider = FutureProvider.family<void, Goal>((ref, goal) async {
  final db = ref.read(databaseProvider);
  await db.update(db.goals).replace(goal);
});

final deleteGoalProvider = FutureProvider.family<void, int>((ref, id) async {
  final db = ref.read(databaseProvider);
  await (db.delete(db.goals)..where((t) => t.id.equals(id))).go();
});