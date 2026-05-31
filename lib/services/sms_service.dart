import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart' hide Value; // <-- evita conflito com Drift
import 'package:drift/drift.dart' show Value;
import 'sms_parser.dart';
import '../database/database.dart';
import '../providers/transaction_providers.dart';

class SmsService {
  static final Telephony _telephony = Telephony.instance;

  /// Inicializa o listener de SMS.
  /// Agora recebe um WidgetRef (disponível em ConsumerStatefulWidget).
  static Future<void> initialize(WidgetRef ref) async {
    final status = await Permission.sms.request();

    if (status.isGranted) {
      _telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          _processSms(message, ref);
        },
        onBackgroundMessage: (SmsMessage message) {
          _processSms(message, ref);
        },
        listenInBackground: false,
      );
    }
  }

  static void _processSms(SmsMessage message, WidgetRef ref) {
    final smsBody = message.body ?? '';
    final sender = message.address ?? 'Desconhecido';

    final transaction = SmsParser.parse(smsBody, sender);
    if (transaction != null) {
      final txCompanion = TransactionsCompanion(
        amount: Value(transaction.amount),
        type: Value(transaction.type),
        category: const Value('SMS'),
        description: Value(transaction.description ?? 'Transação via SMS'),
        date: Value(DateTime.now()),
        source: Value(transaction.source),
        smsId: const Value.absent(),
      );

      ref.read(addTransactionProvider(txCompanion));
    }
  }
}