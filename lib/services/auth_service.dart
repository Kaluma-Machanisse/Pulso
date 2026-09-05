import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/auth_config.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// Faz login silencioso com as credenciais fixas.
  static Future<bool> signIn() async {
    // Se já estiver logado e a sessão for válida, não faz nada.
    final currentSession = _supabase.auth.currentSession;
    if (currentSession != null && !currentSession.isExpired) {
      return true;
    }

    try {
      await _supabase.auth
          .signInWithPassword(
            email: AuthConfig.email,
            password: AuthConfig.password,
          )
          .timeout(const Duration(seconds: 8));
      return true;
    } catch (e) {
      // Sem rede / Supabase indisponível: a app funciona na mesma offline
      // com a base de dados local, por isso não bloqueamos o arranque.
      debugPrint('Login automático falhou (a app continua offline): $e');
      return false;
    }
  }
}