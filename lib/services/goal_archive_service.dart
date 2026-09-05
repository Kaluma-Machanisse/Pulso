import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'goal_reminder_service.dart';

/// Arquiva automaticamente os objectivos 100% concluídos (não os apaga).
///
/// - progresso >= 100  → `isCompleted = true`, `archivedAt = agora`
///   e cancela os lembretes agendados.
/// - progresso < 100 e estava arquivado → desarquiva (caso o utilizador
///   tenha editado o progresso para baixo).
class GoalArchiveService {
  GoalArchiveService._();

  /// Aplica a regra a um único objectivo. Devolve o objectivo actualizado.
  static Future<Goal> apply(AppDatabase db, Goal goal) async {
    final completo = goal.progressPercentage >= 100;

    if (completo && goal.archivedAt == null) {
      final atualizado = goal.copyWith(
        isCompleted: true,
        archivedAt: Value(DateTime.now()),
      );
      await db.update(db.goals).replace(atualizado);
      await GoalReminderService.cancelForGoal(goal.id);
      return atualizado;
    }

    if (!completo && goal.archivedAt != null) {
      final atualizado = goal.copyWith(
        isCompleted: false,
        archivedAt: const Value(null),
      );
      await db.update(db.goals).replace(atualizado);
      return atualizado;
    }

    return goal;
  }

  /// Varre todos os objectivos (chamar no arranque da app).
  static Future<void> sweep(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final goals = await db.select(db.goals).get();
    for (final goal in goals) {
      await apply(db, goal);
    }
  }
}
