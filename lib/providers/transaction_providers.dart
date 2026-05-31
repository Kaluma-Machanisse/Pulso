import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../database/database.dart';
import 'database_provider.dart';   // <-- import correto

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