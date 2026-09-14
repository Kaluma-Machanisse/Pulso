import 'package:flutter/material.dart';
import 'pulso_theme.dart';

/// Acesso rápido ao tema — `context.colors`, `context.textTheme`,
/// `context.pulso` — em vez de repetir `Theme.of(context)` em todo o lado.
extension BuildContextThemeX on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colors => appTheme.colorScheme;
  TextTheme get textTheme => appTheme.textTheme;
  bool get isDark => appTheme.brightness == Brightness.dark;
  PulsoPalette get pulso => PulsoPalette.of(this);
}
