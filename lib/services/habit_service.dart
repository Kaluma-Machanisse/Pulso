import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'goal_progress_service.dart';
import 'task_reminder_service.dart';

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Tarefas-hábito: check-in diário durante um período fixo
/// (`habitStartDate` .. `habitEndDate`). Progresso = dias com check-in ÷
/// dias totais do período.
class HabitService {
  HabitService._();

  static int totalDias(Task t) {
    if (t.habitStartDate == null || t.habitEndDate == null) return 0;
    return _dia(t.habitEndDate!).difference(_dia(t.habitStartDate!)).inDays + 1;
  }

  static Future<int> diasFeitos(AppDatabase db, int taskId) async {
    final rows = await (db.select(db.habitCheckins)
          ..where((c) => c.taskId.equals(taskId)))
        .get();
    return rows.length;
  }

  static Future<int> percent(AppDatabase db, Task t) async {
    final total = totalDias(t);
    if (total <= 0) return 0;
    final feitos = await diasFeitos(db, t.id);
    return ((feitos / total) * 100).round().clamp(0, 100);
  }

  static Future<bool> feitoHoje(AppDatabase db, int taskId) async {
    final hoje = _dia(DateTime.now());
    final row = await (db.select(db.habitCheckins)
          ..where((c) => c.taskId.equals(taskId))
          ..where((c) => c.date.equals(hoje)))
        .getSingleOrNull();
    return row != null;
  }

  /// Alterna o check-in de hoje (marca se não estava, remove se já estava).
  /// Devolve o novo estado (true = marcado).
  static Future<bool> alternarHoje(WidgetRef ref, Task task) async {
    final db = ref.read(databaseProvider);
    final hoje = _dia(DateTime.now());
    final existente = await (db.select(db.habitCheckins)
          ..where((c) => c.taskId.equals(task.id))
          ..where((c) => c.date.equals(hoje)))
        .getSingleOrNull();

    bool marcado;
    if (existente != null) {
      await (db.delete(db.habitCheckins)..where((c) => c.id.equals(existente.id)))
          .go();
      marcado = false;
    } else {
      await db.into(db.habitCheckins).insert(HabitCheckinsCompanion.insert(
            taskId: task.id,
            date: hoje,
          ));
      marcado = true;
    }

    await GoalProgressService.recompute(ref, task.goalId);
    return marcado;
  }

  /// Fecha sozinho os hábitos cujo período já terminou: marca `habitClosed`
  /// e `isCompleted`, e actualiza o objectivo ligado com o resultado final.
  static Future<void> sweepClose(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final hoje = _dia(DateTime.now());
    final tasks = await (db.select(db.tasks)
          ..where((t) => t.isHabit.equals(true))
          ..where((t) => t.habitClosed.equals(false)))
        .get();

    for (final t in tasks) {
      if (t.habitEndDate == null || !_dia(t.habitEndDate!).isBefore(hoje)) {
        continue; // período ainda não terminou
      }
      await db.update(db.tasks).replace(
            t.copyWith(habitClosed: true, isCompleted: true),
          );
      await TaskReminderService.cancelForTask(t.id);
      await GoalProgressService.recompute(ref, t.goalId);
    }
  }
}
