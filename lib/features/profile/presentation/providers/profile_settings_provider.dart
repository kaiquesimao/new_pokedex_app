import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/locale_resolver.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const showMegaEvolutionsKey = 'profile_show_mega_evolutions';
const showOtherFormsKey = 'profile_show_other_forms';
const notifyNewPokemonKey = 'profile_notify_new_pokemon';
const notifyAppUpdatesKey = 'profile_notify_app_updates';
const appLanguageKey = 'profile_app_language';
const interfaceLanguageKey = 'profile_interface_language';

/// Resolves app language from prefs, with system detection on first launch.
String resolveInitialAppLanguage(SharedPreferences prefs) {
  final stored = prefs.getString(appLanguageKey);
  if (stored != null) return stored;

  final legacy = prefs.getString(interfaceLanguageKey);
  // ponytail: pre-i18n app always defaulted interface language to pt-BR and
  // persisted it on any settings save — only trust an explicit en-US choice.
  if (legacy == 'en-US') return legacy!;

  return LocaleResolver.fromPlatform().tag;
}

/// Persists detected language on first launch so later reads stay consistent.
Future<void> seedInitialAppLanguage(SharedPreferences prefs) async {
  if (prefs.containsKey(appLanguageKey)) return;
  await prefs.setString(appLanguageKey, resolveInitialAppLanguage(prefs));
}

ProfileSettings readStoredProfileSettings(SharedPreferences prefs) {
  final appLanguage = resolveInitialAppLanguage(prefs);

  return ProfileSettings(
    showMegaEvolutions: prefs.getBool(showMegaEvolutionsKey) ?? true,
    showOtherForms: prefs.getBool(showOtherFormsKey) ?? true,
    notifyNewPokemon: prefs.getBool(notifyNewPokemonKey) ?? true,
    notifyAppUpdates: prefs.getBool(notifyAppUpdatesKey) ?? false,
    appLanguage: appLanguage,
  );
}

class ProfileSettingsNotifier extends Notifier<ProfileSettings> {
  @override
  ProfileSettings build() =>
      readStoredProfileSettings(ref.watch(sharedPreferencesProvider));

  Future<void> _persist(ProfileSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(showMegaEvolutionsKey, settings.showMegaEvolutions);
    await prefs.setBool(showOtherFormsKey, settings.showOtherForms);
    await prefs.setBool(notifyNewPokemonKey, settings.notifyNewPokemon);
    await prefs.setBool(notifyAppUpdatesKey, settings.notifyAppUpdates);
    await prefs.setString(appLanguageKey, settings.appLanguage);
  }

  Future<void> setShowMegaEvolutions({required bool value}) async {
    state = state.copyWith(showMegaEvolutions: value);
    await _persist(state);
  }

  Future<void> setShowOtherForms({required bool value}) async {
    state = state.copyWith(showOtherForms: value);
    await _persist(state);
  }

  Future<void> setNotifyNewPokemon({required bool value}) async {
    state = state.copyWith(notifyNewPokemon: value);
    await _persist(state);
  }

  Future<void> setNotifyAppUpdates({required bool value}) async {
    state = state.copyWith(notifyAppUpdates: value);
    await _persist(state);
  }

  Future<void> toggleAppLanguage() async {
    final next = state.appLanguage == 'pt-BR' ? 'en-US' : 'pt-BR';
    state = state.copyWith(appLanguage: next);
    await _persist(state);
  }
}

final profileSettingsProvider =
    NotifierProvider<ProfileSettingsNotifier, ProfileSettings>(
      ProfileSettingsNotifier.new,
    );
