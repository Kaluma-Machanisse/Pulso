/// MODELO — copia este ficheiro para `auth_config.dart` e preenche os valores.
/// O ficheiro real está no .gitignore e nunca deve ser versionado.
class AuthConfig {
  static const String email = String.fromEnvironment(
    'AUTH_EMAIL',
    defaultValue: 'o-teu-email@exemplo.com',
  );

  static const String password = String.fromEnvironment(
    'AUTH_PASSWORD',
    defaultValue: '',
  );
}
