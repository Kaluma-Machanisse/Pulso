import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// Design tokens da Pulso — fundação do design system.
///
/// Poucas cores, hierarquia clara. O azul é o único elemento de marca;
/// tudo o resto é neutro. Tarefas, Objectivos e Carteira partilham a
/// mesma paleta — nada de "uma cor por secção".
/// ---------------------------------------------------------------------
class PulsoColors {
  PulsoColors._();

  // ---- Marca (azul profundo, nunca saturado/infantil) ----
  static const primaryLight = Color(0xFF2955C4);
  static const primaryHoverLight = Color(0xFF2148AD);
  static const primaryActiveLight = Color(0xFF1A3A93);

  static const primaryDark = Color(0xFF6E93F5);
  static const primaryHoverDark = Color(0xFF89A8F7);
  static const primaryActiveDark = Color(0xFFA8C0FA);

  // ---- Superfícies — claro ----
  static const bgLight = Color(0xFFF6F7F9);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceElevatedLight = Color(0xFFFBFCFE);
  static const borderLight = Color(0xFFE6E8ED);
  static const borderSubtleLight = Color(0xFFEFF1F4);

  // ---- Superfícies — escuro (navy quase-negro, nunca preto puro) ----
  // Fundo bem mais escuro que as superfícies para que os cartões "flutuem"
  // por contraste, em vez de dependerem de bordas visíveis.
  static const bgDark = Color(0xFF0A0C10);
  static const surfaceDark = Color(0xFF15181F);
  static const surfaceElevatedDark = Color(0xFF1B1F28);
  static const borderDark = Color(0xFF2A303B);
  static const borderSubtleDark = Color(0xFF1C2028);

  // ---- Texto — claro (quase-preto, nunca preto absoluto) ----
  static const textPrimaryLight = Color(0xFF161A22);
  static const textSecondaryLight = Color(0xFF4A5160);
  static const textMutedLight = Color(0xFF7B8291);
  static const textDisabledLight = Color(0xFFB7BCC6);

  // ---- Texto — escuro (branco suave, nunca branco puro) ----
  static const textPrimaryDark = Color(0xFFEDEFF3);
  static const textSecondaryDark = Color(0xFFB2B8C4);
  static const textMutedDark = Color(0xFF838A99);
  static const textDisabledDark = Color(0xFF4E5563);

  // ---- Semânticas (mesmas nos dois temas; usadas só quando preciso) ----
  static const success = Color(0xFF1E9E6B);
  static const warning = Color(0xFFC98A2E);
  static const danger = Color(0xFFD64851);
  static const infoLight = Color(0xFF3D72D8);
  static const infoDark = Color(0xFF7DA0F0);
}

/// Escala de espaçamento — nunca usar valores arbitrários fora daqui.
class PulsoSpace {
  PulsoSpace._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const smd = 12.0;
  static const md = 16.0;
  static const mlg = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xl2 = 40.0;
  static const xl3 = 48.0;
  static const xl4 = 64.0;
}

/// Raios de canto — pequeno para inputs/botões, médio para cards, grande
/// para folhas/modais. Nunca "tudo em cápsula".
class PulsoRadius {
  PulsoRadius._();
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 28.0;
}

/// Paleta resolvida para o brightness actual — para widgets que precisam
/// de tokens que o [ColorScheme] do Material não cobre (surfaceElevated,
/// borderSubtle, textSecondary vs textMuted, hover/active, info).
class PulsoPalette extends ThemeExtension<PulsoPalette> {
  final Color primary, primaryHover, primaryActive;
  final Color background, surface, surfaceElevated;
  final Color border, borderSubtle;
  final Color textPrimary, textSecondary, textMuted, textDisabled;
  final Color success, warning, danger, info;

  const PulsoPalette({
    required this.primary,
    required this.primaryHover,
    required this.primaryActive,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  static const light = PulsoPalette(
    primary: PulsoColors.primaryLight,
    primaryHover: PulsoColors.primaryHoverLight,
    primaryActive: PulsoColors.primaryActiveLight,
    background: PulsoColors.bgLight,
    surface: PulsoColors.surfaceLight,
    surfaceElevated: PulsoColors.surfaceElevatedLight,
    border: PulsoColors.borderLight,
    borderSubtle: PulsoColors.borderSubtleLight,
    textPrimary: PulsoColors.textPrimaryLight,
    textSecondary: PulsoColors.textSecondaryLight,
    textMuted: PulsoColors.textMutedLight,
    textDisabled: PulsoColors.textDisabledLight,
    success: PulsoColors.success,
    warning: PulsoColors.warning,
    danger: PulsoColors.danger,
    info: PulsoColors.infoLight,
  );

  static const dark = PulsoPalette(
    primary: PulsoColors.primaryDark,
    primaryHover: PulsoColors.primaryHoverDark,
    primaryActive: PulsoColors.primaryActiveDark,
    background: PulsoColors.bgDark,
    surface: PulsoColors.surfaceDark,
    surfaceElevated: PulsoColors.surfaceElevatedDark,
    border: PulsoColors.borderDark,
    borderSubtle: PulsoColors.borderSubtleDark,
    textPrimary: PulsoColors.textPrimaryDark,
    textSecondary: PulsoColors.textSecondaryDark,
    textMuted: PulsoColors.textMutedDark,
    textDisabled: PulsoColors.textDisabledDark,
    success: PulsoColors.success,
    warning: PulsoColors.warning,
    danger: PulsoColors.danger,
    info: PulsoColors.infoDark,
  );

  static PulsoPalette of(BuildContext context) =>
      Theme.of(context).extension<PulsoPalette>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  PulsoPalette copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryActive,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return PulsoPalette(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryActive: primaryActive ?? this.primaryActive,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  PulsoPalette lerp(ThemeExtension<PulsoPalette>? other, double t) {
    if (other is! PulsoPalette) return this;
    return PulsoPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryActive: Color.lerp(primaryActive, other.primaryActive, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

class PulsoTheme {
  PulsoTheme._();

  static ThemeData light() => _build(PulsoPalette.light, Brightness.light);
  static ThemeData dark() => _build(PulsoPalette.dark, Brightness.dark);

  static ThemeData _build(PulsoPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: PulsoColors.primaryLight,
      brightness: brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: Colors.white,
      primaryContainer: p.primary.withValues(alpha: isDark ? 0.22 : 0.10),
      onPrimaryContainer: p.primary,
      secondary: p.info,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textMuted,
      outline: p.border,
      outlineVariant: p.borderSubtle,
      surfaceContainerHighest: p.surfaceElevated,
      error: p.danger,
      onError: Colors.white,
      errorContainer: p.danger.withValues(alpha: isDark ? 0.22 : 0.10),
      onErrorContainer: p.danger,
    );

    // Hierarquia: Familjen Grotesk para títulos/números de destaque,
    // Hanken Grotesk para tudo o resto (corpo, labels, formulários).
    final textTheme = TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'FamiljenGrotesk',
          fontWeight: FontWeight.w700,
          fontSize: 36,
          height: 1.1,
          letterSpacing: -0.5,
          color: p.textPrimary),
      displayMedium: TextStyle(
          fontFamily: 'FamiljenGrotesk',
          fontWeight: FontWeight.w700,
          fontSize: 30,
          height: 1.15,
          letterSpacing: -0.3,
          color: p.textPrimary),
      headlineLarge: TextStyle(
          fontFamily: 'FamiljenGrotesk',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          height: 1.2,
          color: p.textPrimary),
      headlineMedium: TextStyle(
          fontFamily: 'FamiljenGrotesk',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 1.25,
          color: p.textPrimary),
      headlineSmall: TextStyle(
          fontFamily: 'FamiljenGrotesk',
          fontWeight: FontWeight.w600,
          fontSize: 17,
          height: 1.3,
          color: p.textPrimary),
      titleLarge: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: p.textPrimary),
      titleMedium: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: p.textPrimary),
      titleSmall: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          color: p.textPrimary),
      bodyLarge: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.4,
          color: p.textPrimary),
      bodyMedium: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w400,
          fontSize: 13.5,
          height: 1.4,
          color: p.textSecondary),
      bodySmall: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.35,
          color: p.textMuted),
      labelLarge: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.1,
          color: p.textPrimary),
      labelMedium: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
          letterSpacing: 0.8,
          color: p.textMuted),
      labelSmall: TextStyle(
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w500,
          fontSize: 10.5,
          color: p.textMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      fontFamily: 'HankenGrotesk',
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: [p],
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        iconTheme: IconThemeData(color: p.textPrimary),
      ),
      dividerTheme: DividerThemeData(
          color: p.borderSubtle, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulsoRadius.md),
          // Em modo escuro os cartões "flutuam" só por contraste de cor —
          // sem borda visível, como nas apps de referência (fundo quase
          // negro, cartão graphite). Em modo claro mantém-se a borda subtil.
          side: isDark ? BorderSide.none : BorderSide(color: p.borderSubtle),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.borderSubtle,
        linearMinHeight: 6,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: p.border, width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? p.primary : p.border),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceElevated,
        side: BorderSide(color: p.borderSubtle),
        labelStyle: textTheme.labelSmall,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulsoRadius.sm)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: PulsoSpace.md, vertical: PulsoSpace.smd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulsoRadius.sm),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulsoRadius.sm),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulsoRadius.sm),
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PulsoRadius.sm),
          borderSide: BorderSide(color: p.danger),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: p.border,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: PulsoSpace.lg, vertical: PulsoSpace.smd),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PulsoRadius.sm)),
          textStyle: textTheme.titleSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PulsoRadius.sm)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PulsoRadius.sm)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulsoRadius.lg)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(PulsoRadius.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulsoRadius.lg)),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.textPrimary,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: p.background),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulsoRadius.sm)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primary.withValues(alpha: isDark ? 0.24 : 0.12),
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            textTheme.labelSmall?.copyWith(
                color: states.contains(WidgetState.selected)
                    ? p.primary
                    : p.textMuted,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500)),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color:
                states.contains(WidgetState.selected) ? p.primary : p.textMuted)),
      ),
    );
  }
}
