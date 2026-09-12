import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'notification_service.dart';

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Agenda os lembretes das tarefas.
///
/// - Tarefas normais (com `dueDate`): véspera às 18:00 + dia às 09:00.
/// - Tarefas-hábito: **um ou mais** lembretes por dia (`HabitReminders`), do
///   hoje até ao fim do período (janela rolante de 90 dias — `rescheduleAll`
///   no arranque estende sempre que for preciso).
///
/// Tarefas concluídas, fechadas ou sem data não geram lembretes.
class TaskReminderService {
  TaskReminderService._();

  static const int _dueSlots = 10;
  static int _dueBase(int taskId) => 500000 + taskId * _dueSlots;

  // 1000 ids por tarefa: até ~10 lembretes/dia durante os 90 dias da janela.
  static const int _habitSlots = 1000;
  static const int _habitHorizonDays = 90;
  static int _habitBase(int taskId) => 700000 + taskId * _habitSlots;

  static Future<void> cancelForTask(int taskId) async {
    final b = _dueBase(taskId);
    await NotificationService.cancelRange(b, b + _dueSlots - 1);
    final hb = _habitBase(taskId);
    await NotificationService.cancelRange(hb, hb + _habitSlots - 1);
  }

  static Future<void> rescheduleForTask(WidgetRef ref, Task task) async {
    await cancelForTask(task.id);
    if (task.isHabit) {
      await _rescheduleHabit(ref, task);
    } else {
      await _rescheduleDueDate(task);
    }
  }

  static Future<void> _rescheduleDueDate(Task task) async {
    if (task.isCompleted || task.dueDate == null) return;

    final d = task.dueDate!;
    final b = _dueBase(task.id);

    await NotificationService.scheduleAt(
      id: b,
      title: 'Tarefa vence amanhã',
      body: '"${task.title}" (${task.priority})',
      when: DateTime(d.year, d.month, d.day - 1, 18),
    );
    await NotificationService.scheduleAt(
      id: b + 1,
      title: 'Tarefa vence hoje',
      body: '"${task.title}" (${task.priority})',
      when: DateTime(d.year, d.month, d.day, 9),
    );
  }

  static Future<void> _rescheduleHabit(WidgetRef ref, Task task) async {
    if (task.isCompleted || task.habitClosed) return;
    if (task.habitStartDate == null || task.habitEndDate == null) return;

    final db = ref.read(databaseProvider);
    final reminders = await (db.select(db.habitReminders)
          ..where((r) => r.taskId.equals(task.id)))
        .get();
    if (reminders.isEmpty) return;

    final now = DateTime.now();
    final fim = _dia(task.habitEndDate!);
    final limite = now.add(const Duration(days: _habitHorizonDays));
    final base = _habitBase(task.id);

    var dia = _dia(task.habitStartDate!).isAfter(_dia(now))
        ? _dia(task.habitStartDate!)
        : _dia(now);
    var slot = 0;

    while (!dia.isAfter(fim) && dia.isBefore(limite) && slot < _habitSlots) {
      for (final r in reminders) {
        if (slot >= _habitSlots) break;
        final quando = DateTime(dia.year, dia.month, dia.day, r.hour, r.minute);
        if (quando.isAfter(now)) {
          await NotificationService.scheduleAt(
            id: base + slot,
            title: 'Hora do hábito',
            body: '"${task.title}" — marca quando fizeres.',
            when: quando,
          );
          slot++;
        }
      }
      dia = dia.add(const Duration(days: 1));
    }
  }

  static Future<void> rescheduleAll(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final tasks = await db.select(db.tasks).get();
    for (final t in tasks) {
      await rescheduleForTask(ref, t);
    }
  }
}
