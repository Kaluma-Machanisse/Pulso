import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart' hide Value;
import 'transaction_ingest_service.dart';

class SmsService {
  static final Telephony _telephony = Telephony.instance;

  /// Inicializa o listener de SMS. Recebe um WidgetRef (disponível num
  /// ConsumerStatefulWidget).
  static Future<void> initialize(WidgetRef ref) async {
    final status = await Permission.sms.request();
    if (!status.isGranted) return;

    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) => _processSms(message, ref),
      onBackgroundMessage: (SmsMessage message) => _processSms(message, ref),
      listenInBackground: false,
    );
  }

  static Future<void> _processSms(SmsMessage message, WidgetRef ref) async {
    await TransactionIngestService.ingest(
      ref,
      text: message.body ?? '',
      sender: message.address ?? 'Desconhecido',
      origem: 'SMS',
    );
  }
}
