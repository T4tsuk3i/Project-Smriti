import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0A1012);
  static const surface = Color(0xFF121C1F);
  static const surfaceHigh = Color(0xFF162327);
  static const border = Color(0xFF243438);
  static const text = Color(0xFFE9E4D8);
  static const muted = Color(0xFF9BACAA);
  static const faint = Color(0xFF6F8381);
  static const mint = Color(0xFF83D3BB);
  static const peach = Color(0xFFE6B18A);
  static const danger = Color(0xFFEF9B8F);
  static const warning = Color(0xFFE7C27A);
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.mint,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.mint,
        onPrimary: const Color(0xFF07110E),
        secondary: AppColors.peach,
        onSecondary: const Color(0xFF1B0F08),
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.danger,
      );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'sans-serif',
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: const TextStyle(
        fontFamily: 'serif',
        fontSize: 34,
        height: 1.1,
        letterSpacing: -0.7,
        color: AppColors.text,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'serif',
        fontSize: 26,
        height: 1.15,
        letterSpacing: -0.4,
        color: AppColors.text,
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'serif',
        fontSize: 22,
        height: 1.2,
        color: AppColors.text,
      ),
      titleMedium: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      bodyMedium: const TextStyle(
        fontSize: 15.5,
        height: 1.6,
        color: AppColors.text,
      ),
      bodySmall: const TextStyle(
        fontSize: 13,
        height: 1.45,
        color: AppColors.muted,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
        color: AppColors.mint,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceHigh,
      hintStyle: const TextStyle(color: AppColors.faint, height: 1.5),
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.mint, width: 1.3),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.mint,
        foregroundColor: const Color(0xFF07110E),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mint,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.mint.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.text : AppColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected ? AppColors.mint : AppColors.muted,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: const TextStyle(color: AppColors.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
  );
}
