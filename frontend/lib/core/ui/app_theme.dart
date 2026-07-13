import 'package:flutter/material.dart';

abstract final class IronColors {
  static const Color darkBackground = Color(0xFF0D0D0B);
  static const Color darkSurface = Color(0xFF1C1A17);
  static const Color darkElevated = Color(0xFF252220);
  static const Color darkAccent = Color(0xFFE8532A);
  static const Color darkTextPrimary = Color(0xFFEDE8E0);
  static const Color darkTextSecondary = Color(0xFF888880);
  static const Color darkBorder = Color(0xFF333330);

  static const Color lightBackground = Color(0xFFEDE8E0);
  static const Color lightSurface = Color(0xFFFAF8F4);
  static const Color lightElevated = Color(0xFFF5F2EC);
  static const Color lightAccent = Color(0xFFC84820);
  static const Color lightTextPrimary = Color(0xFF1C1A17);
  static const Color lightTextSecondary = Color(0xFF5A5650);
  static const Color lightBorder = Color(0xFFD4CFC6);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
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
  final textPri =
      isDark ? IronColors.darkTextPrimary : IronColors.lightTextPrimary;
  final textSec =
      isDark ? IronColors.darkTextSecondary : IronColors.lightTextSecondary;
  final border = isDark ? IronColors.darkBorder : IronColors.lightBorder;

  final colorScheme = ColorScheme(
    brightness: brightness,
    surface: surface,
    primary: accent,
    onPrimary: Colors.white,
    secondary: accent,
    onSecondary: Colors.white,
    error: accent,
    onError: Colors.white,
    onSurface: textPri,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: textPri,
          height: 1.2),
      headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: textPri,
          height: 1.3),
      titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: textPri,
          height: 1.4),
      bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPri,
          height: 1.6),
      bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSec,
          height: 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, IronSpacing.minTapTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IronRadius.sm),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
        minimumSize:
            const Size(IronSpacing.minTapTarget, IronSpacing.minTapTarget),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: elevated,
      hintStyle: TextStyle(color: textSec),
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
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(IronRadius.sm),
        borderSide: const BorderSide(color: IronColors.darkAccent, width: 1.5),
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
    dividerTheme: DividerThemeData(
      color: border,
      thickness: 0.5,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: elevated,
      selectedColor: isDark ? const Color(0xFF2A1A14) : const Color(0xFFF5E8E0),
      labelStyle:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPri),
      side: BorderSide(color: border, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IronRadius.xs),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: IronSpacing.sm, vertical: IronSpacing.xs),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: textPri, fontSize: 14),
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
