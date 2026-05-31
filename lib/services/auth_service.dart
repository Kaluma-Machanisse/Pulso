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
      await _supabase.auth.signInWithPassword(
        email: AuthConfig.email,
        password: AuthConfig.password,
      );
      return true;
    } catch (e) {
      debugPrint('Erro no login automático: $e');
      return false;
    }
  }
}