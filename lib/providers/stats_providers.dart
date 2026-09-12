import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import 'database_provider.dart';

// Agregação mensal: mapa ano.mes -> {receitas, despesas}
final monthlyStatsProvider = StreamProvider<Map<String, Map<String, double>>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.transactions).watch().map((txList) {
    final Map<String, Map<String, double>> monthly = {};
    for (final tx in txList) {
      final key = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
      monthly.putIfAbsent(key, () => {'receitas': 0.0, 'despesas': 0.0});
      if (tx.type == 'receita') {
        monthly[key]!['receitas'] = (monthly[key]!['receitas'] ?? 0) + tx.amount;
      } else {
        monthly[key]!['despesas'] = (monthly[key]!['despesas'] ?? 0) + tx.amount;
      }
    }
    return monthly;
  });
});

/// Gastos do mês corrente agrupados por semana (semana 1 = dias 1-7, etc.),
/// para identificar o pico de despesa dentro do mês.
class WeekSpend {
  final int semana; // 1..5
  final double total;
  WeekSpend(this.semana, this.total);
}

final weeklySpendProvider = StreamProvider<List<WeekSpend>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.transactions).watch().map((txList) {
    final now = DateTime.now();
    final Map<int, double> porSemana = {};
    for (final tx in txList) {
      if (tx.type != 'despesa') continue;
      if (tx.date.year != now.year || tx.date.month != now.month) continue;
      final semana = ((tx.date.day - 1) ~/ 7) + 1;
      porSemana[semana] = (porSemana[semana] ?? 0) + tx.amount;
    }
    final lista = porSemana.entries.map((e) => WeekSpend(e.key, e.value)).toList()
      ..sort((a, b) => a.semana.compareTo(b.semana));
    return lista;
  });
});

// Progresso dos objectivos (lista simples)
final goalsProgressProvider = StreamProvider<List<Goal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.goals).watch();
});