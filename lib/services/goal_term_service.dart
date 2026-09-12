import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

/// Prazo do objectivo — deixou de ser escolha manual: é calculado a partir
/// da data-alvo, e recalculado sempre que a app abre (um objectivo "amadurece"
/// de Longo → Médio → Curto prazo à medida que a data se aproxima).
class GoalTermService {
  GoalTermService._();

  static const curto = 'Curto prazo';
  static const medio = 'Médio prazo';
  static const longo = 'Longo prazo';

  static const _limiteCurtoDias = 30; // ≤ 1 mês
  static const _limiteMedioDias = 182; // ≤ ~6 meses

  /// Sem data-alvo, não há como calcular — assume Médio prazo.
  static String compute(DateTime? targetDate) {
    if (targetDate == null) return medio;
    final hoje = DateTime.now();
    final alvo = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final dias =
        alvo.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
    if (dias <= _limiteCurtoDias) return curto; // inclui já atrasados
    if (dias <= _limiteMedioDias) return medio;
    return longo;
  }

  /// Recalcula o prazo de todos os objectivos activos (não arquivados).
  static Future<void> recomputeAll(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final goals = await (db.select(db.goals)
          ..where((g) => g.archivedAt.isNull()))
        .get();

    for (final g in goals) {
      final novoTermo = compute(g.targetDate);
      if (novoTermo != g.term) {
        await db.update(db.goals).replace(g.copyWith(term: novoTermo));
      }
    }
  }
}
