import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/theme/geoguide_theme.dart';

void main() {
  test('exploration design tokens match the approved visual contract', () {
    const tokens = GeoGuideTheme.exploration;
    expect(tokens.primary, const Color(0xFF006D63));
    expect(tokens.cefi, const Color(0xFF7138D8));
    expect(tokens.accent, const Color(0xFFFFAE49));
    expect(tokens.surface, const Color(0xFFF6F9F8));
    expect(tokens.textPrimary, const Color(0xFF203632));
    expect(tokens.route, const Color(0xFF1677E8));
    expect(tokens.space8, 8);
    expect(tokens.cardRadius, 20);
  });

  test('exploration palette has accessible text pairs and local scope', () {
    final exploration = GeoGuideTheme.explorationShell();
    final baseline = GeoGuideTheme.light();

    expect(
      _contrast(
        exploration.colorScheme.onPrimary,
        exploration.colorScheme.primary,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(
        exploration.colorScheme.onSecondary,
        exploration.colorScheme.secondary,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(
        exploration.colorScheme.onSurface,
        exploration.colorScheme.surface,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(
        GeoGuideTheme.exploration.textPrimary,
        GeoGuideTheme.exploration.accent,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(
        GeoGuideTheme.exploration.route,
        exploration.colorScheme.surface,
      ),
      greaterThanOrEqualTo(3),
    );
    expect(exploration.useMaterial3, isTrue);
    expect(
      baseline.colorScheme.primary,
      isNot(exploration.colorScheme.primary),
    );
    expect(baseline.cardTheme, isNot(exploration.cardTheme));
  });
}

double _contrast(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}
