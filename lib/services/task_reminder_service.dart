import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'notification_service.dart';

/// Agenda os lembretes das tarefas com data de vencimento:
///  - véspera às 18:00  ("amanhã vence …")
///  - dia às 09:00      ("vence hoje …")
///
/// Tarefas concluídas ou sem data não geram lembretes.
class TaskReminderService {
  TaskReminderService._();

  // Faixa de ids reservada por tarefa (não colide com os objectivos, que
  // usam 100000 + goalId*100).
  static const int _slots = 10;
  static int _base(int taskId) => 500000 + taskId * _slots;

  static Future<void> cancelForTask(int taskId) {
    final b = _base(taskId);
    return NotificationService.cancelRange(b, b + _slots - 1);
  }

  static Future<void> rescheduleForTask(Task task) async {
    await cancelForTask(task.id);
    if (task.isCompleted || task.dueDate == null) return;

    final d = task.dueDate!;
    final b = _base(task.id);

    // Véspera às 18:00
    await NotificationService.scheduleAt(
      id: b,
      title: 'Tarefa vence amanhã',
      body: '"${task.title}" (${task.priority})',
      when: DateTime(d.year, d.month, d.day - 1, 18),
    );
    // Dia às 09:00
    await NotificationService.scheduleAt(
      id: b + 1,
      title: 'Tarefa vence hoje',
      body: '"${task.title}" (${task.priority})',
      when: DateTime(d.year, d.month, d.day, 9),
    );
  }

  static Future<void> rescheduleAll(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final tasks = await db.select(db.tasks).get();
    for (final t in tasks) {
      await rescheduleForTask(t);
    }
  }
}
