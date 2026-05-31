import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Inicializa o plugin e cria o canal de notificações (Android obrigatório).
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Abrir');
    const initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(initSettings);

    // Criar o canal de notificações para Android
    const androidChannel = AndroidNotificationChannel(
      'pulso_lembretes',   // ID do canal
      'Lembretes Pulso',   // Nome visível
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
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pulso_lembretes',
        'Lembretes Pulso',
        importance: Importance.high,
        priority: Priority.high,
      ),
      linux: LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.normal,
      ),
    );
    await _plugin.show(0, title, body, details);
  }
}