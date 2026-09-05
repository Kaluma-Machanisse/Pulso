/// MODELO — copia este ficheiro para `supabase_config.dart` e preenche os valores.
/// O ficheiro real está no .gitignore e nunca deve ser versionado.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://o-teu-projecto.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'a-tua-anon-key',
  );
}
