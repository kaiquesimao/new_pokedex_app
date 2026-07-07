import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const themeModeStorageKey = 'theme_mode';

ThemeMode readStoredThemeMode(SharedPreferences prefs) {
  final index = prefs.getInt(themeModeStorageKey);
  if (index != null && index >= 0 && index < ThemeMode.values.length) {
    return ThemeMode.values[index];
  }
  return ThemeMode.system;
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() =>
      readStoredThemeMode(ref.watch(sharedPreferencesProvider));

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeModeStorageKey, mode.index);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
