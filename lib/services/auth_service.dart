import 'package:supabase_flutter/supabase_flutter.dart';

/// Autenticação real do Supabase — sem credenciais embutidas na app.
/// O utilizador entra com o seu próprio email/password no [LoginScreen];
/// a sessão fica guardada pelo próprio supabase_flutter entre arranques.
class AuthService {
  static final _supabase = Supabase.instance.client;

  static User? get currentUser => _supabase.auth.currentUser;

  static bool get isLoggedIn {
    final session = _supabase.auth.currentSession;
    return session != null && !session.isExpired;
  }

  static Stream<AuthState> get onAuthStateChange =>
      _supabase.auth.onAuthStateChange;

  /// Devolve `null` em sucesso, ou uma mensagem de erro legível.
  static Future<String?> signIn(String email, String password) async {
    try {
      await _supabase.auth
          .signInWithPassword(email: email.trim(), password: password)
          .timeout(const Duration(seconds: 12));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível ligar ao servidor. Verifica a ligação e tenta novamente.';
    }
  }

  /// Devolve `null` em sucesso, ou uma mensagem de erro legível.
  static Future<String?> signUp(String email, String password) async {
    try {
      await _supabase.auth
          .signUp(email: email.trim(), password: password)
          .timeout(const Duration(seconds: 12));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível ligar ao servidor. Verifica a ligação e tenta novamente.';
    }
  }

  static Future<void> signOut() => _supabase.auth.signOut();
}
