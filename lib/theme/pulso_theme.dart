import 'package:flutter/material.dart';

/// Paleta e temas da Pulso.
///
/// Uma cor de marca (azul), near-black e neutros frios — as mesmas fichas
/// servem todas as abas. Cores de estado (sucesso/aviso/erro) são separadas
/// da cor de marca.
class PulsoColors {
  PulsoColors._();

  // Marca
  static const primaryLight = Color(0xFF2F6BED);
  static const primaryDark = Color(0xFF5B8CFF);

  // Neutros — claro
  static const inkLight = Color(0xFF15171C);
  static const mutedLight = Color(0xFF707784);
  static const lineLight = Color(0xFFE7E9EE);
  static const bgLight = Color(0xFFF7F8FA);
  static const surfaceLight = Color(0xFFFFFFFF);

  // Neutros — escuro
  static const inkDark = Color(0xFFF1F2F5);
  static const mutedDark = Color(0xFF8A909C);
  static const lineDark = Color(0xFF262A31);
  static const bgDark = Color(0xFF0F1115);
  static const surfaceDark = Color(0xFF181B21);

  // Estado (iguais nos dois temas)
  static const success = Color(0xFF1FA971);
  static const warning = Color(0xFFE8A13C);
  static const danger = Color(0xFFE5484D);
}

class PulsoTheme {
  PulsoTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? PulsoColors.primaryDark : PulsoColors.primaryLight;
    final ink = isDark ? PulsoColors.inkDark : PulsoColors.inkLight;
    final muted = isDark ? PulsoColors.mutedDark : PulsoColors.mutedLight;
    final line = isDark ? PulsoColors.lineDark : PulsoColors.lineLight;
    final bg = isDark ? PulsoColors.bgDark : PulsoColors.bgLight;
    final surface = isDark ? PulsoColors.surfaceDark : PulsoColors.surfaceLight;

    final scheme = ColorScheme.fromSeed(
      seedColor: PulsoColors.primaryLight,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: isDark ? const Color(0xFF07142E) : Colors.white,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      outlineVariant: line,
      error: PulsoColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'HankenGrotesk',
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: ink,
        ),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: line),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: line,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
