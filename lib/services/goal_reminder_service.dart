import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'notification_service.dart';

/// Agenda (e cancela) os lembretes de cada objectivo.
///
/// Regra:
///  - 1 notificação garantida no dia da data-alvo (qualquer importância);
///  - N lembretes por semana até à data-alvo, conforme a importância:
///      Baixa = 1x · Média = 2x · Alta = 3x · Crítica = 4x
///  - objectivos completos ou sem data-alvo não geram lembretes;
///  - só se agenda uma janela de 90 dias para a frente (os de longo prazo
///    são reagendados sempre que a app abre).
class GoalReminderService {
  GoalReminderService._();

  static const int _slotsPerGoal = 100; // ids reservados por objectivo
  static const int _dueSlot = 99;       // último slot = notificação da data-alvo
  static const int _horizonDays = 90;
  static const int _reminderHour = 9;

  static int _baseId(int goalId) => 100000 + goalId * _slotsPerGoal;

  /// Dias da semana (DateTime.weekday: 1=Seg … 7=Dom) para cada frequência.
  static List<int> _weekdaysFor(String importance) {
    switch (importance) {
      case 'Baixa':
        return const [3]; // Qua
      case 'Alta':
        return const [1, 3, 5]; // Seg, Qua, Sex
      case 'Crítica':
        return const [1, 3, 5, 7]; // Seg, Qua, Sex, Dom
      case 'Média':
      default:
        return const [2, 5]; // Ter, Sex
    }
  }

  /// Cancela todos os lembretes agendados de um objectivo.
  static Future<void> cancelForGoal(int goalId) {
    final base = _baseId(goalId);
    return NotificationService.cancelRange(base, base + _slotsPerGoal - 1);
  }

  /// Recalcula e reagenda os lembretes de um objectivo.
  static Future<void> rescheduleForGoal(Goal goal) async {
    await cancelForGoal(goal.id);

    if (goal.isCompleted || goal.targetDate == null) return;

    final now = DateTime.now();
    final target = goal.targetDate!;
    final dueMoment =
        DateTime(target.year, target.month, target.day, _reminderHour);
    final base = _baseId(goal.id);

    // 1) Notificação no dia da data-alvo.
    if (dueMoment.isAfter(now)) {
      await NotificationService.scheduleAt(
        id: base + _dueSlot,
        title: 'Data-alvo do objectivo hoje',
        body:
            '"${goal.title}" tem data-alvo hoje e está a ${goal.progressPercentage}%.',
        when: dueMoment,
      );
    }

    // 2) Lembretes periódicos até à data-alvo (janela de 90 dias).
    final weekdays = _weekdaysFor(goal.importance);
    final limite = now.add(const Duration(days: _horizonDays));
    var dia = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1)); // começa amanhã
    var slot = 0;

    while (slot < _dueSlot &&
        dia.isBefore(dueMoment) &&
        dia.isBefore(limite)) {
      if (weekdays.contains(dia.weekday)) {
        final quando =
            DateTime(dia.year, dia.month, dia.day, _reminderHour);
        if (quando.isAfter(now)) {
          await NotificationService.scheduleAt(
            id: base + slot,
            title: 'Lembrete de objectivo (${goal.importance})',
            body:
                '"${goal.title}" — ${goal.progressPercentage}% concluído. Data-alvo ${target.day}/${target.month}/${target.year}.',
            when: quando,
          );
          slot++;
        }
      }
      dia = dia.add(const Duration(days: 1));
    }
  }

  /// Reagenda os lembretes de todos os objectivos (chamar no arranque da app).
  static Future<void> rescheduleAll(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final goals = await db.select(db.goals).get();
    for (final goal in goals) {
      await rescheduleForGoal(goal);
    }
  }
}
