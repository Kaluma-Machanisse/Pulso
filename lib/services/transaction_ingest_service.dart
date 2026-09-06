import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'sms_parser.dart';

/// Ponto único onde SMS e notificações push viram transações.
/// Analisa o texto, evita duplicados pela referência e grava.
class TransactionIngestService {
  TransactionIngestService._();

  /// Devolve `true` se gravou uma transação nova.
  static Future<bool> ingest(
    WidgetRef ref, {
    required String text,
    required String sender,
    required String origem, // 'SMS' | 'push'
  }) async {
    final parsed = SmsParser.parse(text, sender);
    if (parsed == null) return false;

    final db = ref.read(databaseProvider);

    // Dedup: já existe uma transação com esta referência?
    final ref0 = parsed.reference;
    if (ref0 != null && ref0.isNotEmpty) {
      final existe = await (db.select(db.transactions)
            ..where((t) => t.smsId.equals(ref0)))
          .getSingleOrNull();
      if (existe != null) return false;
    }

    await db.into(db.transactions).insert(TransactionsCompanion(
          amount: Value(parsed.amount),
          type: Value(parsed.type),
          category: const Value('SMS'),
          description:
              Value(parsed.description ?? 'Transação via $origem ($sender)'),
          date: Value(DateTime.now()),
          source: Value('${parsed.source} · $origem'),
          smsId: (ref0 != null && ref0.isNotEmpty)
              ? Value(ref0)
              : const Value.absent(),
        ));
    return true;
  }
}
