import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value, OrderingTerm;
import '../database/database.dart';
import 'database_provider.dart';
import 'transaction_providers.dart';

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.budgets)
        ..orderBy([(b) => OrderingTerm(expression: b.category)]))
      .watch();
});

final upsertBudgetProvider =
    FutureProvider.family<void, ({int? id, String category, double limit})>(
        (ref, b) async {
  final db = ref.read(databaseProvider);
  if (b.id == null) {
    await db.into(db.budgets).insert(BudgetsCompanion.insert(
          category: b.category,
          monthlyLimit: b.limit,
        ));
  } else {
    await (db.update(db.budgets)..where((t) => t.id.equals(b.id!))).write(
      BudgetsCompanion(
        category: Value(b.category),
        monthlyLimit: Value(b.limit),
      ),
    );
  }
});

final deleteBudgetProvider = FutureProvider.family<void, int>((ref, id) async {
  final db = ref.read(databaseProvider);
  await (db.delete(db.budgets)..where((t) => t.id.equals(id))).go();
});

/// Estado de um orçamento no mês corrente.
class BudgetStatus {
  final Budget budget;
  final double spent;
  double get limit => budget.monthlyLimit;
  double get pct => limit <= 0 ? 0 : (spent / limit).clamp(0, 2).toDouble();
  bool get over => spent > limit;
  BudgetStatus(this.budget, this.spent);
}

final budgetStatusProvider = Provider<List<BudgetStatus>>((ref) {
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
  final gastos = {
    for (final e in ref.watch(currentMonthExpensesByCategoryProvider))
      e.key: e.value
  };
  return budgets
      .map((b) => BudgetStatus(b, gastos[b.category] ?? 0))
      .toList();
});

/// Quantos orçamentos estão ultrapassados este mês.
final overBudgetCountProvider = Provider<int>((ref) =>
    ref.watch(budgetStatusProvider).where((s) => s.over).length);
