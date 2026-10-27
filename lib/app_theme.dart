import 'package:flutter/material.dart';

abstract final class AppColors {
  // Paper and ink.
  static const paper = Color(0xFFF6F1E7);
  static const paperRaised = Color(0xFFFBF7EF);
  static const paperDeep = Color(0xFFEFE7D8);
  static const ink = Color(0xFF23201B);
  static const muted = Color(0xFF6F675C);
  static const faint = Color(0xFF9A8F80);
  static const line = Color(0xFFDDD2C0);

  // Accents.
  static const rust = Color(0xFFA9503B);
  static const rustSoft = Color(0xFFE8C9BD);
  static const olive = Color(0xFF5E6B52);
  static const danger = Color(0xFF9E3D32);
  static const warning = Color(0xFF8A6A2F);

  // Existing widget names, mapped to the new palette.
  static const background = paper;
  static const surface = paperRaised;
  static const surfaceHigh = paperDeep;
  static const border = line;
  static const text = ink;
  static const accent = rust;
  static const secondary = olive;
  static const mint = accent;
  static const peach = secondary;
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.rust,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.rust,
        onPrimary: Colors.white,
        secondary: AppColors.olive,
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
        fontFamily: 'serif',
        fontSize: 31,
        height: 1.12,
        letterSpacing: -0.5,
        color: AppColors.ink,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'serif',
        fontSize: 24,
        height: 1.18,
        letterSpacing: -0.25,
        color: AppColors.ink,
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'serif',
        fontSize: 20,
        height: 1.2,
        color: AppColors.ink,
      ),
      titleMedium: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontSize: 15.5,
        height: 1.65,
        color: AppColors.ink,
      ),
      bodySmall: const TextStyle(
        fontSize: 13.2,
        height: 1.5,
        color: AppColors.muted,
      ),
      labelSmall: const TextStyle(
        fontSize: 10.5,
        letterSpacing: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.faint,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paperRaised,
      hintStyle: const TextStyle(color: AppColors.faint, height: 1.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.rust, width: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.rust,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.paperRaised,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.rust : AppColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 21,
          color: selected ? AppColors.rust : AppColors.muted,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(color: AppColors.paper),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
  );
}
