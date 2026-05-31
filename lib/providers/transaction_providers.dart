import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../database/database.dart';
import 'database_provider.dart';
import 'filter_providers.dart'; // <-- novo import

// --- Providers existentes (inalterados) ---
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.transactions)
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();
});

final addTransactionProvider =
    FutureProvider.family<void, TransactionsCompanion>((ref, tx) async {
  final db = ref.read(databaseProvider);
  await db.into(db.transactions).insert(tx);
});

final deleteTransactionProvider =
    FutureProvider.family<void, int>((ref, id) async {
  final db = ref.read(databaseProvider);
  await (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
});

final balanceProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.transactions).watch().map((txList) {
    double balance = 0;
    for (final tx in txList) {
      if (tx.type == 'receita') {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  });
});

// --- Novo: Provider de transações filtradas ---
final filteredTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final allTxsAsync = ref.watch(transactionsProvider);
  final filter = ref.watch(financeFilterProvider);

  return allTxsAsync.when(
    data: (txList) {
      var filtered = txList;
      // Filtrar por tipo
      if (filter.type != 'todas') {
        filtered = filtered.where((tx) => tx.type == filter.type).toList();
      }
      // Filtrar por categoria
      if (filter.category != 'Todas') {
        filtered =
            filtered.where((tx) => tx.category == filter.category).toList();
      }
      // Filtrar por mês (opcional, se implementares no filtro)
      if (filter.month != null) {
        filtered =
            filtered.where((tx) => tx.date.month == filter.month).toList();
      }
      // Filtrar por ano (opcional, se implementares no filtro)
      if (filter.year != null) {
        filtered =
            filtered.where((tx) => tx.date.year == filter.year).toList();
      }
      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});