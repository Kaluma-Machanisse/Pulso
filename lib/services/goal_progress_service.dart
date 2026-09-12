import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'goal_archive_service.dart';
import 'goal_reminder_service.dart';

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Progresso automático dos objectivos a partir das tarefas ligadas.
///
///   progresso = média da "percentagem" de cada tarefa
///
/// Tarefa normal: 0% ou 100% (isCompleted). Tarefa-hábito: dias com
/// check-in ÷ dias do período (mesmo enquanto ainda está a decorrer).
///
/// Se o objectivo não tiver nenhuma tarefa ligada, o progresso mantém-se
/// manual (o que estiver guardado / o slider).
class GoalProgressService {
  GoalProgressService._();

  static Future<double> _percentTarefa(AppDatabase db, Task t) async {
    if (!t.isHabit) return t.isCompleted ? 100 : 0;
    if (t.habitStartDate == null || t.habitEndDate == null) {
      return t.isCompleted ? 100 : 0;
    }
    final totalDias =
        _dia(t.habitEndDate!).difference(_dia(t.habitStartDate!)).inDays + 1;
    if (totalDias <= 0) return 0;
    final feitos = await (db.select(db.habitCheckins)
          ..where((c) => c.taskId.equals(t.id)))
        .get();
    return (feitos.length / totalDias * 100).clamp(0, 100);
  }

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

    double soma = 0;
    for (final t in tasks) {
      soma += await _percentTarefa(db, t);
    }
    final pct = (soma / tasks.length).round();

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
