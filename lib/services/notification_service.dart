import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Chamado quando o utilizador toca numa notificação (app aberta,
  /// em segundo plano, ou fechada — ver [initialize] e [checkLaunchTap]).
  /// Recebe o `payload` definido ao criar/agendar a notificação.
  static void Function(String? payload)? onTap;

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
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
    );

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
    String? payload,
  }) async {
    await _plugin.show(id, title, body, _details, payload: payload);
  }

  /// Agenda uma notificação única para um instante futuro.
  /// Se [when] já passou, não faz nada.
  static Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
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
        payload: payload,
      );
    } catch (e) {
      // Desktop/Linux não suporta zonedSchedule — ignora em vez de rebentar.
      if (kDebugMode) debugPrint('scheduleAt($id) ignorado: $e');
    }
  }

  /// Agenda uma notificação que se repete todos os dias à mesma hora,
  /// sozinha (o sistema trata da repetição, não é preciso reagendar).
  static Future<void> scheduleDailyAt({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    String? payload,
  }) async {
    final agora = tz.TZDateTime.now(tz.local);
    var proximo =
        tz.TZDateTime(tz.local, agora.year, agora.month, agora.day, hour, minute);
    if (proximo.isBefore(agora)) {
      proximo = proximo.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        proximo,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      // Desktop/Linux não suporta zonedSchedule — ignora em vez de rebentar.
      if (kDebugMode) debugPrint('scheduleDailyAt($id) ignorado: $e');
    }
  }

  /// Se a app foi aberta a partir de um toque numa notificação (app estava
  /// fechada), devolve o `payload` dessa notificação. Chamar uma vez no
  /// arranque, depois de [initialize].
  static Future<String?> checkLaunchTap() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        return details.notificationResponse?.payload;
      }
    } catch (e) {
      // Desktop/Linux não implementa isto — ignora em vez de rebentar.
      if (kDebugMode) debugPrint('checkLaunchTap ignorado: $e');
    }
    return null;
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
