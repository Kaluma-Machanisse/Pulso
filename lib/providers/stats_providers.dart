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

// Progresso dos objectivos (lista simples)
final goalsProgressProvider = StreamProvider<List<Goal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.goals).watch();
});