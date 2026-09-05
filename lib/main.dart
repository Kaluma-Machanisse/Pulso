import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/notification_service.dart';
import 'providers/settings_providers.dart';
import 'theme/pulso_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await NotificationService.initialize();

  runApp(const ProviderScope(child: PulsoApp()));
}

class PulsoApp extends ConsumerWidget {
  const PulsoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Pulso',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: PulsoTheme.light(),
      darkTheme: PulsoTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
