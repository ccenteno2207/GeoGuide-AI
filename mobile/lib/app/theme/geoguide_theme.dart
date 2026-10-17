import 'package:flutter/material.dart';

abstract final class GeoGuideTheme {
  static const exploration = GeoGuideExplorationTokens();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B5E55),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }

  /// Scoped to the exploration shell. Driving and modal routes keep [light].
  static ThemeData explorationShell() {
    final colors =
        ColorScheme.fromSeed(
          seedColor: exploration.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: exploration.primary,
          onPrimary: Colors.white,
          secondary: exploration.cefi,
          onSecondary: Colors.white,
          surface: exploration.surface,
          onSurface: exploration.textPrimary,
          primaryContainer: const Color(0xFFD7EFEB),
          onPrimaryContainer: const Color(0xFF123D38),
          secondaryContainer: const Color(0xFFEDE3FF),
          onSecondaryContainer: const Color(0xFF32156B),
          tertiary: exploration.accent,
          onTertiary: exploration.textPrimary,
          outline: const Color(0xFF72817E),
        );

    return light().copyWith(
      colorScheme: colors,
      scaffoldBackgroundColor: exploration.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: exploration.surface,
        foregroundColor: exploration.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: exploration.textPrimary,
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: const Color(0x1A203632),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(exploration.cardRadius),
          side: const BorderSide(color: Color(0xFFDCE7E4)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: EdgeInsets.symmetric(
            horizontal: exploration.space16,
            vertical: exploration.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(exploration.controlRadius),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: exploration.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(exploration.controlRadius),
          ),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}

/// Semantic visual values for Rutea's exploration shell.
final class GeoGuideExplorationTokens {
  const GeoGuideExplorationTokens();

  final Color primary = const Color(0xFF006D63);
  final Color cefi = const Color(0xFF7138D8);
  final Color accent = const Color(0xFFFFAE49);
  final Color surface = const Color(0xFFF6F9F8);
  final Color textPrimary = const Color(0xFF203632);
  final Color route = const Color(0xFF1677E8);

  final double space4 = 4;
  final double space8 = 8;
  final double space12 = 12;
  final double space16 = 16;
  final double cardRadius = 20;
  final double controlRadius = 14;
}
