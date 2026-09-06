import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'transaction_ingest_service.dart';

/// Lê as notificações push de apps bancárias / carteiras e transforma-as em
/// transações (mesmo parser das SMS). Só Android.
///
/// A permissão "Acesso a notificações" é sensível e concedida pelo utilizador
/// nas Definições do Android — abrimo-la a partir das Configurações da app.
class BankNotificationService {
  BankNotificationService._();

  static StreamSubscription<ServiceNotificationEvent>? _sub;

  static bool get _supported => !kIsWeb && Platform.isAndroid;

  static Future<bool> isEnabled() async {
    if (!_supported) return false;
    return NotificationListenerService.isPermissionGranted();
  }

  /// Abre as Definições do Android; devolve true quando a permissão fica activa.
  static Future<bool> requestPermission() async {
    if (!_supported) return false;
    return NotificationListenerService.requestPermission();
  }

  /// Pistas (package ou título) que sugerem uma app financeira.
  static const _hints = [
    'mpesa', 'm-pesa', 'vodacom', 'emola', 'e-mola', 'mkesh', 'ponto24',
    'bim', 'millennium', 'bci', 'standardbank', 'standard bank', 'absa',
    'fnb', 'nedbank', 'letshego', 'moza', 'ecobank', 'socremo', 'banco',
    'carteira', 'wallet', 'pay',
  ];

  static Future<void> start(WidgetRef ref) async {
    if (!_supported || _sub != null) return;
    if (!await NotificationListenerService.isPermissionGranted()) return;

    _sub = NotificationListenerService.notificationsStream.listen((e) async {
      if (e.hasRemoved || e.onGoing) return;

      final texto = '${e.title}\n${e.content}'.trim();
      if (texto.length < 8) return;

      final chave = '${e.packageName} ${e.title}'.toLowerCase();
      final pareceBanco = _hints.any(chave.contains);

      // Se não parece financeira, deixamos passar à mesma: o parser é
      // restritivo (exige valor + verbo de transação), portanto raramente
      // apanha lixo. Mas registamos a origem correcta.
      await TransactionIngestService.ingest(
        ref,
        text: texto,
        sender: pareceBanco && e.title.isNotEmpty ? e.title : e.packageName,
        origem: 'push',
      );
    });
  }

  static Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
