import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Fuso horário usado para agendar notificações.
  /// Moçambique (Maputo) é CAT / UTC+2 e não tem horário de verão.
  /// TODO: detectar automaticamente se a app passar a ter utilizadores fora de MZ.
  static const String _timeZone = 'Africa/Maputo';

  static const _androidDetails = AndroidNotificationDetails(
    'pulso_lembretes',
    'Lembretes Pulso',
    channelDescription: 'Notificações de tarefas e objectivos',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _linuxDetails = LinuxNotificationDetails(
    urgency: LinuxNotificationUrgency.normal,
  );
  static const _details = NotificationDetails(
    android: _androidDetails,
    linux: _linuxDetails,
  );

  /// Inicializa o plugin, o fuso horário e o canal Android.
  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(_timeZone));
    } catch (_) {
      // fica em UTC se o nome do fuso não existir na base tz
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Abrir');
    const initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );
    await _plugin.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      'pulso_lembretes',
      'Lembretes Pulso',
      description: 'Notificações de tarefas e objectivos',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Mostra uma notificação imediatamente.
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _plugin.show(id, title, body, _details);
  }

  /// Agenda uma notificação única para um instante futuro.
  /// Se [when] já passou, não faz nada.
  static Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Desktop/Linux não suporta zonedSchedule — ignora em vez de rebentar.
      if (kDebugMode) debugPrint('scheduleAt($id) ignorado: $e');
    }
  }

  /// Cancela uma notificação agendada pelo seu id.
  static Future<void> cancel(int id) => _plugin.cancel(id);

  /// Cancela um intervalo contíguo de ids (usado para limpar todos os
  /// lembretes de um objectivo de uma vez).
  static Future<void> cancelRange(int firstId, int lastId) async {
    for (var id = firstId; id <= lastId; id++) {
      await _plugin.cancel(id);
    }
  }
}
