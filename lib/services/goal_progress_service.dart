import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import 'goal_archive_service.dart';
import 'goal_reminder_service.dart';

/// Progresso automático dos objectivos a partir das tarefas ligadas.
///
///   progresso = tarefas concluídas ÷ tarefas totais do objectivo  (arredondado)
///
/// Se o objectivo não tiver nenhuma tarefa ligada, o progresso mantém-se
/// manual (o que estiver guardado / o slider).
class GoalProgressService {
  GoalProgressService._();

  /// Recalcula o progresso de um objectivo a partir das suas tarefas.
  /// Se chegar a 100%, o objectivo é arquivado; se descer, é desarquivado.
  static Future<void> recompute(WidgetRef ref, int? goalId) async {
    if (goalId == null) return;
    final db = ref.read(databaseProvider);

    final goal = await (db.select(db.goals)..where((g) => g.id.equals(goalId)))
        .getSingleOrNull();
    if (goal == null) return;

    final tasks =
        await (db.select(db.tasks)..where((t) => t.goalId.equals(goalId))).get();
    if (tasks.isEmpty) return; // sem tarefas → progresso continua manual

    final done = tasks.where((t) => t.isCompleted).length;
    final pct = (done / tasks.length * 100).round();

    var atual = goal;
    if (pct != goal.progressPercentage) {
      atual = goal.copyWith(progressPercentage: pct);
      await db.update(db.goals).replace(atual);
    }
    // Mantém arquivo e lembretes coerentes com o novo progresso.
    final pos = await GoalArchiveService.apply(db, atual);
    await GoalReminderService.rescheduleForGoal(pos);
  }

  /// Recalcula todos os objectivos que têm pelo menos uma tarefa ligada.
  /// Chamar no arranque da app.
  static Future<void> recomputeAll(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final ids = (await db.select(db.tasks).get())
        .map((t) => t.goalId)
        .whereType<int>()
        .toSet();
    for (final id in ids) {
      await recompute(ref, id);
    }
  }
}
