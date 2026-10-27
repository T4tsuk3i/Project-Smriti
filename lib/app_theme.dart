import 'package:flutter/material.dart';

abstract final class AppColors {
  // Warm paper.
  static const paper = Color(0xFFFBF3E8);
  static const paperRaised = Color(0xFFFFFFFF);
  static const paperDeep = Color(0xFFF6EBDD);
  static const ink = Color(0xFF2B211B);
  static const muted = Color(0xFF74685C);
  static const faint = Color(0xFFA19586);
  static const line = Color(0xFFEEE2D2);

  // Accents.
  static const rust = Color(0xFFD95F32);
  static const rustDark = Color(0xFFB64A22);
  static const rustSoft = Color(0xFFFBE0D4);
  static const peach = Color(0xFFFFD8C2);
  static const sage = Color(0xFF7E9F6B);
  static const sageSoft = Color(0xFFE6EFDB);
  static const yellow = Color(0xFFD9A93E);
  static const yellowSoft = Color(0xFFFBF0CE);
  static const orange = Color(0xFFD9823F);
  static const orangeSoft = Color(0xFFFBE6D2);
  static const lilac = Color(0xFF9278B8);
  static const lilacSoft = Color(0xFFEFE7F8);
  static const danger = Color(0xFFC05245);
  static const warning = Color(0xFFB7842F);

  // Existing widget names.
  static const background = paper;
  static const surface = paperRaised;
  static const surfaceHigh = paperDeep;
  static const border = line;
  static const text = ink;
  static const accent = rust;
  static const secondary = sage;
  static const mint = accent;
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.rust,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.rust,
        onPrimary: Colors.white,
        secondary: AppColors.sage,
        onSecondary: Colors.white,
        surface: AppColors.paperRaised,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.paper,
    fontFamily: 'sans-serif',
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: const TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.08,
        letterSpacing: -0.9,
        color: AppColors.ink,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.4,
        color: AppColors.ink,
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 19,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
        color: AppColors.ink,
      ),
      titleMedium: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontSize: 15.5,
        height: 1.6,
        color: AppColors.ink,
      ),
      bodySmall: const TextStyle(
        fontSize: 13,
        height: 1.5,
        color: AppColors.muted,
      ),
      labelSmall: const TextStyle(
        fontSize: 10.5,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
        color: AppColors.faint,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paperDeep,
      hintStyle: const TextStyle(color: AppColors.faint, height: 1.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.rust, width: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.rust,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.rust,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.muted),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(color: AppColors.paper),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
  );
}
