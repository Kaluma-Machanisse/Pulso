import 'package:flutter_riverpod/flutter_riverpod.dart';
//import '../database/database.dart';
import '../providers/database_provider.dart';  // <-- adicionado
import 'notification_service.dart';

class ReminderService {
  static Future<void> checkAndNotify(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // 1. Tarefas pendentes
    final tasks = await db.select(db.tasks).get();
    for (final task in tasks) {
      if (task.isCompleted) continue;
      if (task.dueDate != null) {
        final due = DateTime(
            task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (due == today || due == tomorrow) {
          final when = due == today ? 'hoje' : 'amanhã';
          await NotificationService.showNotification(
            title: 'Tarefa pendente',
            body: '"${task.title}" vence $when.',
          );
        }
      }
    }

    // 2. Objectivos com progresso < 50% e data-alvo próxima (nos próximos 7 dias)
    final goals = await db.select(db.goals).get();
    for (final goal in goals) {
      if (goal.isCompleted) continue;
      if (goal.progressPercentage < 50 && goal.targetDate != null) {
        final target = DateTime(
            goal.targetDate!.year, goal.targetDate!.month, goal.targetDate!.day);
        final daysLeft = target.difference(today).inDays;
        if (daysLeft >= 0 && daysLeft <= 7) {
          await NotificationService.showNotification(
            title: 'Objectivo com pouco progresso',
            body:
                '"${goal.title}" está a ${goal.progressPercentage}% e faltam $daysLeft dias.',
          );
        }
      }
    }
  }
}