import 'package:flutter/material.dart';

abstract final class IronColors {
  static const Color darkBackground = Color(0xFF0D0D0B);
  static const Color darkSurface = Color(0xFF1C1A17);
  static const Color darkElevated = Color(0xFF252220);

  // Suffisamment clair pour conserver un contraste >= 4.5:1 sur les
  // surfaces sombres, avec un texte sombre sur les boutons remplis.
  static const Color darkAccent = Color(0xFFF0643E);
  static const Color darkError = Color(0xFFFF6B5E);
  static const Color darkTextPrimary = Color(0xFFEDE8E0);
  static const Color darkTextSecondary = Color(0xFF888880);
  static const Color darkBorder = Color(0xFF77736D);

  static const Color lightBackground = Color(0xFFEDE8E0);
  static const Color lightSurface = Color(0xFFFAF8F4);
  static const Color lightElevated = Color(0xFFF5F2EC);

  // Plus sombre que l'ancienne teinte afin de rester lisible comme texte
  // d'action sur les surfaces claires.
  static const Color lightAccent = Color(0xFFB23B17);
  static const Color lightError = Color(0xFFB3261E);
  static const Color lightTextPrimary = Color(0xFF1C1A17);
  static const Color lightTextSecondary = Color(0xFF5A5650);
  static const Color lightBorder = Color(0xFF8A857D);

  static const Color successDark = Color(0xFF81C784);
  static const Color successLight = Color(0xFF2E7D32);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color warningLight = Color(0xFFE65100);
}

abstract final class IronSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double minTapTarget = 48.0;
}

abstract final class IronRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

ThemeData buildIronDarkTheme() => _buildTheme(Brightness.dark);
ThemeData buildIronLightTheme() => _buildTheme(Brightness.light);

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final bg = isDark ? IronColors.darkBackground : IronColors.lightBackground;
  final surface = isDark ? IronColors.darkSurface : IronColors.lightSurface;
  final elevated = isDark ? IronColors.darkElevated : IronColors.lightElevated;
  final accent = isDark ? IronColors.darkAccent : IronColors.lightAccent;
  final error = isDark ? IronColors.darkError : IronColors.lightError;
  final textPri =
      isDark ? IronColors.darkTextPrimary : IronColors.lightTextPrimary;
  final textSec =
      isDark ? IronColors.darkTextSecondary : IronColors.lightTextSecondary;
  final border = isDark ? IronColors.darkBorder : IronColors.lightBorder;
  final warning = isDark ? IronColors.warningDark : IronColors.warningLight;
  final accentContainer =
      isDark ? const Color(0xFF44241B) : const Color(0xFFF5DED5);
  final onAccentContainer =
      isDark ? IronColors.darkTextPrimary : const Color(0xFF5E1C09);

  final onAccent = isDark ? IronColors.darkSurface : Colors.white;
  final onError = isDark ? IronColors.darkBackground : Colors.white;

  final colorScheme = ColorScheme(
    brightness: brightness,
    surface: surface,
    primary: accent,
    onPrimary: onAccent,
    primaryContainer: accentContainer,
    onPrimaryContainer: onAccentContainer,
    secondary: accent,
    onSecondary: onAccent,
    secondaryContainer: accentContainer,
    onSecondaryContainer: onAccentContainer,
    tertiary: warning,
    onTertiary:
        isDark ? IronColors.darkBackground : IronColors.lightTextPrimary,
    error: error,
    onError: onError,
    onSurface: textPri,
    onSurfaceVariant: textSec,
    outline: border,
    outlineVariant: border,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: textPri,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textPri,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: textPri,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textPri,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textSec,
        height: 1.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: border,
        disabledForegroundColor: textSec,
        minimumSize: const Size(double.infinity, IronSpacing.minTapTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IronRadius.sm),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPri,
        side: BorderSide(color: border, width: 1.5),
        minimumSize: const Size(double.infinity, IronSpacing.minTapTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IronRadius.sm),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        minimumSize: const Size(
          IronSpacing.minTapTarget,
          IronSpacing.minTapTarget,
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size.square(IronSpacing.minTapTarget),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: elevated,
      labelStyle: TextStyle(color: textSec),
      hintStyle: TextStyle(color: textSec),
      helperStyle: TextStyle(color: textSec),
      errorStyle: TextStyle(color: error, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IronRadius.sm),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IronRadius.sm),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IronRadius.sm),
        borderSide: BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IronRadius.sm),
        borderSide: BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IronRadius.sm),
        borderSide: BorderSide(color: error, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IronRadius.md),
        side: BorderSide(color: border, width: 0.5),
      ),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 0.5, space: 0),
    chipTheme: ChipThemeData(
      backgroundColor: elevated,
      selectedColor: isDark ? const Color(0xFF44241B) : const Color(0xFFF5E8E0),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPri,
      ),
      side: BorderSide(color: border, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IronRadius.xs),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: IronSpacing.sm,
        vertical: IronSpacing.xs,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: textPri, fontSize: 14),
      actionTextColor: accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IronRadius.sm),
        side: BorderSide(color: border, width: 0.5),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(IronRadius.lg),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textPri,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: textPri,
      ),
      iconTheme: IconThemeData(color: textPri),
    ),
  );
}
