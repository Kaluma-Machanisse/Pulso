import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/notification_service.dart';
import 'services/term_of_day_service.dart';
import 'providers/settings_providers.dart';
import 'theme/pulso_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/banking_terms_screen.dart';

/// Navigator global — permite abrir ecrãs a partir de um toque numa
/// notificação, fora do contexto de um widget (ver [NotificationService.onTap]).
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await NotificationService.initialize();
  NotificationService.onTap = _handleNotificationTap;
  final payloadDeArranque = await NotificationService.checkLaunchTap();
  if (payloadDeArranque != null) {
    // Espera pelo primeiro frame para o Navigator já existir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(payloadDeArranque);
    });
  }

  runApp(const ProviderScope(child: PulsoApp()));
}

void _handleNotificationTap(String? payload) {
  if (payload == TermOfDayService.payload) {
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => BankingTermDetailScreen(termo: TermOfDayService.today()),
    ));
  }
}

class PulsoApp extends ConsumerWidget {
  const PulsoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Pulso',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: PulsoTheme.light(),
      darkTheme: PulsoTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
