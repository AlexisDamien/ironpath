import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/core/ui/app_theme.dart';

void main() {
  test('construit un thème sombre cohérent', () {
    final theme = buildIronDarkTheme();

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.brightness, Brightness.dark);
    expect(theme.elevatedButtonTheme.style, isNotNull);
    expect(theme.inputDecorationTheme.filled, isTrue);
  });

  test('construit un thème clair cohérent', () {
    final theme = buildIronLightTheme();

    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, IronColors.lightBackground);
  });

  test('la cible tactile minimale Material est de 48 dp', () {
    expect(IronSpacing.minTapTarget, 48);
  });
}
