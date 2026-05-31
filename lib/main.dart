import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
//import 'services/auth_service.dart';
import 'services/notification_service.dart';
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

class PulsoApp extends StatelessWidget {
  const PulsoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulso',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // começa pela splash
    );
  }
}