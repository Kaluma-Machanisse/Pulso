import '../data/banking_terms.dart';
import 'notification_service.dart';

/// Escolhe o "termo do dia" e agenda o lembrete diário para o mostrar.
class TermOfDayService {
  TermOfDayService._();

  static const int notificationId = 900000;
  static const String payload = 'termo_do_dia';

  /// Termo de hoje — determinístico pela data, para se manter igual o dia
  /// todo e ir avançando pela lista sem repetir até dar a volta a todos.
  static BankingTerm today([DateTime? data]) {
    final d = data ?? DateTime.now();
    final diaDoAno = int.parse(
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}');
    final indice = diaDoAno % bankingTerms.length;
    return bankingTerms[indice];
  }

  /// Agenda a notificação diária às 9h — repete todos os dias sozinha
  /// (`matchDateTimeComponents: time`), só precisa de ser chamada uma vez
  /// (repete-se sem precisar de a app abrir todos os dias). O título fica
  /// genérico de propósito: o termo em si só é calculado quando o painel
  /// abre, para nunca ficar desactualizado.
  static Future<void> scheduleDaily() async {
    await NotificationService.scheduleDailyAt(
      id: notificationId,
      hour: 9,
      minute: 0,
      title: 'Termo bancário do dia',
      body: 'Toca para veres qual é e o que significa.',
      payload: payload,
    );
  }
}
