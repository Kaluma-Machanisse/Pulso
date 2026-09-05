import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../database/database.dart';
import 'database_provider.dart';

/// Histórico de relatórios mensais, do mais recente para o mais antigo.
final reportsProvider = StreamProvider<List<Report>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.reports)
        ..orderBy([(r) => OrderingTerm.desc(r.month)]))
      .watch();
});
