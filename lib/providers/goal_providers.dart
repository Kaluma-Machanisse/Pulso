import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../database/database.dart';
import 'database_provider.dart';   // <-- importa daqui

/// Objectivos activos (não arquivados) — o que aparece na lista principal.
final goalsProvider = StreamProvider<List<Goal>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.goals)..where((g) => g.archivedAt.isNull())).watch();
});

/// Objectivos arquivados (concluídos a 100%), mais recentes primeiro.
final archivedGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.goals)
        ..where((g) => g.archivedAt.isNotNull())
        ..orderBy([(g) => OrderingTerm.desc(g.archivedAt)]))
      .watch();
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