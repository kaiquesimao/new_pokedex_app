import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const themeModeStorageKey = 'theme_mode';

ThemeMode readStoredThemeMode(SharedPreferences prefs) {
  final index = prefs.getInt(themeModeStorageKey);
  if (index != null && index >= 0 && index < ThemeMode.values.length) {
    return ThemeMode.values[index];
  }
  return ThemeMode.system;
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(super.initial);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeModeStorageKey, mode.index);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier(ThemeMode.system);
});
