import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  const AppTheme();

  static const _darkColors = AppColors();
  static const _lightColors = AppColors.light();

  ThemeData get darkThemeData => _buildTheme(_darkColors, Brightness.dark);
  ThemeData get lightThemeData => _buildTheme(_lightColors, Brightness.light);

  ThemeData _buildTheme(AppColors colors, Brightness brightness) {
    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final textTheme = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors.toColorScheme(brightness),
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colors.onSurface,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colors.onSurfaceVariant,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: colors.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.headlineLarge?.copyWith(
          color: colors.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colors.primaryContainer,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant);
        }),
      ),
      extensions: [colors],
    );
  }
}
