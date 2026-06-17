import 'package:flutter/material.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    background: AppColorsLight.background,
    surface: AppColorsLight.surface,
    textPrimary: AppColorsLight.textPrimary,
    textSecondary: AppColorsLight.textSecondary,
    primary: AppColorsLight.primary,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    background: AppColorsDark.background,
    surface: AppColorsDark.surface,
    textPrimary: AppColorsDark.textPrimary,
    textSecondary: AppColorsDark.textSecondary,
    primary: AppColorsDark.primary,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color primary,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? AppColorsDark.background : Colors.white,
      secondary: primary,
      onSecondary: isDark ? AppColorsDark.background : Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: isDark
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFE8E8E8),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      dividerColor: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.08),
      textTheme: AppTypography.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? primary : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : textSecondary,
            size: 24,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? AppColorsDark.background : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return isDark ? AppColorsDark.background : Colors.white;
            }
            return textPrimary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primary;
            return surface;
          }),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      iconTheme: IconThemeData(color: textPrimary),
    );
  }
}
