import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
//import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'providers/settings_provider.dart';   // <-- novo import
import 'screens/splash_screen.dart';
//import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await NotificationService.initialize();

  runApp(const ProviderScope(child: PulsoApp()));
}

// Muda de StatelessWidget para ConsumerWidget
class PulsoApp extends ConsumerWidget {
  const PulsoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lê as configurações de tema
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Pulso',
      themeMode: settings.themeMode,     // aplica o tema escolhido
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const SplashScreen(),
    );
  }
}