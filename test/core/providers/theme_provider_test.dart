import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('readStoredThemeMode returns persisted value', () async {
    SharedPreferences.setMockInitialValues({
      themeModeStorageKey: ThemeMode.dark.index,
    });
    final prefs = await SharedPreferences.getInstance();

    expect(readStoredThemeMode(prefs), ThemeMode.dark);
  });

  test('readStoredThemeMode defaults to system', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    expect(readStoredThemeMode(prefs), ThemeMode.system);
  });
}
