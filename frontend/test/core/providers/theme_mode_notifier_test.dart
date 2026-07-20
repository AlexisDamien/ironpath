import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ironpath/core/providers/provider_theme.dart';

Future<void> flushAsync() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('le thème sombre est la valeur initiale', () {
    final notifier = ThemeModeNotifier();
    expect(notifier.state, ThemeMode.dark);
    notifier.dispose();
  });

  test('charge le thème clair sauvegardé', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final notifier = ThemeModeNotifier();

    await flushAsync();

    expect(notifier.state, ThemeMode.light);
    notifier.dispose();
  });

  test('charge le thème système sauvegardé', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
    final notifier = ThemeModeNotifier();

    await flushAsync();

    expect(notifier.state, ThemeMode.system);
    notifier.dispose();
  });

  test('setThemeMode met à jour et persiste la valeur', () async {
    final notifier = ThemeModeNotifier();

    await notifier.setThemeMode(ThemeMode.light);

    final preferences = await SharedPreferences.getInstance();
    expect(notifier.state, ThemeMode.light);
    expect(preferences.getString('theme_mode'), 'light');
    notifier.dispose();
  });
}
