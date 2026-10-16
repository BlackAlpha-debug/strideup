import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primaryContainer;
  final Color secondaryFixed;
  final Color error;
  final Color primaryFixed;
  final Color surfaceContainerLowest;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color surfaceContainerLow;
  final Color outlineVariant;
  final Color onPrimaryFixedVariant;
  final Color onPrimaryContainer;
  final Color tertiaryContainer;
  final Color errorContainer;
  final Color secondaryContainer;
  final Color onBackground;
  final Color tertiaryFixed;
  final Color onTertiaryContainer;
  final Color background;
  final Color surfaceContainerHighest;
  final Color onError;
  final Color inverseSurface;
  final Color onTertiary;
  final Color onSecondaryContainer;
  final Color secondary;
  final Color surfaceBright;
  final Color secondaryFixedDim;
  final Color onSecondary;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onPrimary;
  final Color surfaceDim;
  final Color onPrimaryFixed;
  final Color tertiary;
  final Color inversePrimary;
  final Color onErrorContainer;
  final Color primaryFixedDim;
  final Color surfaceTint;
  final Color primary;
  final Color onSurfaceVariant;
  final Color surfaceContainer;
  final Color surface;
  final Color onTertiaryFixedVariant;
  final Color outline;
  final Color inverseOnSurface;
  final Color onSecondaryFixed;
  final Color surfaceContainerHigh;

  const AppColors({
    this.primaryContainer = const Color(0xFF00f2ff),
    this.secondaryFixed = const Color(0xFFc3f400),
    this.error = const Color(0xFFffb4ab),
    this.primaryFixed = const Color(0xFF74f5ff),
    this.surfaceContainerLowest = const Color(0xFF0e0e0e),
    this.onSecondaryFixedVariant = const Color(0xFF3c4d00),
    this.tertiaryFixedDim = const Color(0xFFd1bcff),
    this.onTertiaryFixed = const Color(0xFF23005b),
    this.surfaceContainerLow = const Color(0xFF1c1b1b),
    this.outlineVariant = const Color(0xFF3a494b),
    this.onPrimaryFixedVariant = const Color(0xFF004f54),
    this.onPrimaryContainer = const Color(0xFF006a71),
    this.tertiaryContainer = const Color(0xFFe3d4ff),
    this.errorContainer = const Color(0xFF93000a),
    this.secondaryContainer = const Color(0xFFc3f400),
    this.onBackground = const Color(0xFFe5e2e1),
    this.tertiaryFixed = const Color(0xFFe9ddff),
    this.onTertiaryContainer = const Color(0xFF7318ff),
    this.background = const Color(0xFF131313),
    this.surfaceContainerHighest = const Color(0xFF353534),
    this.onError = const Color(0xFF690005),
    this.inverseSurface = const Color(0xFFe5e2e1),
    this.onTertiary = const Color(0xFF3c0090),
    this.onSecondaryContainer = const Color(0xFF556d00),
    this.secondary = const Color(0xFFffffff),
    this.surfaceBright = const Color(0xFF3a3939),
    this.secondaryFixedDim = const Color(0xFFabd600),
    this.onSecondary = const Color(0xFF283500),
    this.surfaceVariant = const Color(0xFF353534),
    this.onSurface = const Color(0xFFe5e2e1),
    this.onPrimary = const Color(0xFF00363a),
    this.surfaceDim = const Color(0xFF131313),
    this.onPrimaryFixed = const Color(0xFF002022),
    this.tertiary = const Color(0xFFfcf5ff),
    this.inversePrimary = const Color(0xFF00696f),
    this.onErrorContainer = const Color(0xFFffdad6),
    this.primaryFixedDim = const Color(0xFF00dbe7),
    this.surfaceTint = const Color(0xFF00dbe7),
    this.primary = const Color(0xFFe1fdff),
    this.onSurfaceVariant = const Color(0xFFb9cacb),
    this.surfaceContainer = const Color(0xFF201f1f),
    this.surface = const Color(0xFF131313),
    this.onTertiaryFixedVariant = const Color(0xFF5700c9),
    this.outline = const Color(0xFF849495),
    this.inverseOnSurface = const Color(0xFF313030),
    this.onSecondaryFixed = const Color(0xFF161e00),
    this.surfaceContainerHigh = const Color(0xFF2a2a2a),
  });

  const AppColors.light({
    this.primaryContainer = const Color(0xFF00BCD4),
    this.secondaryFixed = const Color(0xFF9EAD00),
    this.error = const Color(0xFFBA1A1A),
    this.primaryFixed = const Color(0xFF74f5ff),
    this.surfaceContainerLowest = const Color(0xFFFFFFFF),
    this.onSecondaryFixedVariant = const Color(0xFF3c4d00),
    this.tertiaryFixedDim = const Color(0xFF9C7EE0),
    this.onTertiaryFixed = const Color(0xFF23005b),
    this.surfaceContainerLow = const Color(0xFFF5F5F5),
    this.outlineVariant = const Color(0xFFBFCFD0),
    this.onPrimaryFixedVariant = const Color(0xFF004f54),
    this.onPrimaryContainer = const Color(0xFF006a71),
    this.tertiaryContainer = const Color(0xFFe3d4ff),
    this.errorContainer = const Color(0xFFFFDAD6),
    this.secondaryContainer = const Color(0xFF9EAD00),
    this.onBackground = const Color(0xFF1C1C1C),
    this.tertiaryFixed = const Color(0xFFe9ddff),
    this.onTertiaryContainer = const Color(0xFF7318ff),
    this.background = const Color(0xFFF5F5F5),
    this.surfaceContainerHighest = const Color(0xFFD6D6D6),
    this.onError = const Color(0xFFFFFFFF),
    this.inverseSurface = const Color(0xFF313030),
    this.onTertiary = const Color(0xFFFFFFFF),
    this.onSecondaryContainer = const Color(0xFF556d00),
    this.secondary = const Color(0xFF1C1C1C),
    this.surfaceBright = const Color(0xFFFFFFFF),
    this.secondaryFixedDim = const Color(0xFF8BA200),
    this.onSecondary = const Color(0xFFFFFFFF),
    this.surfaceVariant = const Color(0xFFE8E8E8),
    this.onSurface = const Color(0xFF1C1C1C),
    this.onPrimary = const Color(0xFFFFFFFF),
    this.surfaceDim = const Color(0xFFE8E8E8),
    this.onPrimaryFixed = const Color(0xFF002022),
    this.tertiary = const Color(0xFF6A3CB5),
    this.inversePrimary = const Color(0xFF00696f),
    this.onErrorContainer = const Color(0xFF410002),
    this.primaryFixedDim = const Color(0xFF00dbe7),
    this.surfaceTint = const Color(0xFF00BCD4),
    this.primary = const Color(0xFF006874),
    this.onSurfaceVariant = const Color(0xFF5C6B6C),
    this.surfaceContainer = const Color(0xFFF0F0F0),
    this.surface = const Color(0xFFFFFFFF),
    this.onTertiaryFixedVariant = const Color(0xFF5700c9),
    this.outline = const Color(0xFF6B7B7C),
    this.inverseOnSurface = const Color(0xFFE5E2E1),
    this.onSecondaryFixed = const Color(0xFF161e00),
    this.surfaceContainerHigh = const Color(0xFFE0E0E0),
  });

  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: primaryContainer,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondaryFixed,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiaryFixedDim,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainer: surfaceContainer,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerLowest: surfaceContainerLowest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
    );
  }

  @override
  AppColors copyWith({
    Color? primaryContainer,
    Color? secondaryFixed,
    Color? error,
    Color? primaryFixed,
    Color? surfaceContainerLowest,
    Color? onSecondaryFixedVariant,
    Color? tertiaryFixedDim,
    Color? onTertiaryFixed,
    Color? surfaceContainerLow,
    Color? outlineVariant,
    Color? onPrimaryFixedVariant,
    Color? onPrimaryContainer,
    Color? tertiaryContainer,
    Color? errorContainer,
    Color? secondaryContainer,
    Color? onBackground,
    Color? tertiaryFixed,
    Color? onTertiaryContainer,
    Color? background,
    Color? surfaceContainerHighest,
    Color? onError,
    Color? inverseSurface,
    Color? onTertiary,
    Color? onSecondaryContainer,
    Color? secondary,
    Color? surfaceBright,
    Color? secondaryFixedDim,
    Color? onSecondary,
    Color? surfaceVariant,
    Color? onSurface,
    Color? onPrimary,
    Color? surfaceDim,
    Color? onPrimaryFixed,
    Color? tertiary,
    Color? inversePrimary,
    Color? onErrorContainer,
    Color? primaryFixedDim,
    Color? surfaceTint,
    Color? primary,
    Color? onSurfaceVariant,
    Color? surfaceContainer,
    Color? surface,
    Color? onTertiaryFixedVariant,
    Color? outline,
    Color? inverseOnSurface,
    Color? onSecondaryFixed,
    Color? surfaceContainerHigh,
  }) {
    return AppColors(
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      error: error ?? this.error,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      onSecondaryFixedVariant:
          onSecondaryFixedVariant ?? this.onSecondaryFixedVariant,
      tertiaryFixedDim: tertiaryFixedDim ?? this.tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed ?? this.onTertiaryFixed,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      onPrimaryFixedVariant:
          onPrimaryFixedVariant ?? this.onPrimaryFixedVariant,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      errorContainer: errorContainer ?? this.errorContainer,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onBackground: onBackground ?? this.onBackground,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      background: background ?? this.background,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onError: onError ?? this.onError,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onTertiary: onTertiary ?? this.onTertiary,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      secondary: secondary ?? this.secondary,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      secondaryFixedDim: secondaryFixedDim ?? this.secondaryFixedDim,
      onSecondary: onSecondary ?? this.onSecondary,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurface: onSurface ?? this.onSurface,
      onPrimary: onPrimary ?? this.onPrimary,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      tertiary: tertiary ?? this.tertiary,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      primary: primary ?? this.primary,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surface: surface ?? this.surface,
      onTertiaryFixedVariant:
          onTertiaryFixedVariant ?? this.onTertiaryFixedVariant,
      outline: outline ?? this.outline,
      inverseOnSurface: inverseOnSurface ?? this.inverseOnSurface,
      onSecondaryFixed: onSecondaryFixed ?? this.onSecondaryFixed,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      error: Color.lerp(error, other.error, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      surfaceContainerLowest: Color.lerp(
        surfaceContainerLowest,
        other.surfaceContainerLowest,
        t,
      )!,
      onSecondaryFixedVariant: Color.lerp(
        onSecondaryFixedVariant,
        other.onSecondaryFixedVariant,
        t,
      )!,
      tertiaryFixedDim: Color.lerp(
        tertiaryFixedDim,
        other.tertiaryFixedDim,
        t,
      )!,
      onTertiaryFixed: Color.lerp(onTertiaryFixed, other.onTertiaryFixed, t)!,
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      )!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      onPrimaryFixedVariant: Color.lerp(
        onPrimaryFixedVariant,
        other.onPrimaryFixedVariant,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      tertiaryContainer: Color.lerp(
        tertiaryContainer,
        other.tertiaryContainer,
        t,
      )!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      onTertiaryContainer: Color.lerp(
        onTertiaryContainer,
        other.onTertiaryContainer,
        t,
      )!,
      background: Color.lerp(background, other.background, t)!,
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      )!,
      onError: Color.lerp(onError, other.onError, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      onSecondaryContainer: Color.lerp(
        onSecondaryContainer,
        other.onSecondaryContainer,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      secondaryFixedDim: Color.lerp(
        secondaryFixedDim,
        other.secondaryFixedDim,
        t,
      )!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      primaryFixedDim: Color.lerp(primaryFixedDim, other.primaryFixedDim, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      onTertiaryFixedVariant: Color.lerp(
        onTertiaryFixedVariant,
        other.onTertiaryFixedVariant,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      inverseOnSurface: Color.lerp(
        inverseOnSurface,
        other.inverseOnSurface,
        t,
      )!,
      onSecondaryFixed: Color.lerp(
        onSecondaryFixed,
        other.onSecondaryFixed,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
    );
  }
}
