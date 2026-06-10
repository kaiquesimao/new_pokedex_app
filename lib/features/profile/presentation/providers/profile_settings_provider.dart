import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const showMegaEvolutionsKey = 'profile_show_mega_evolutions';
const showOtherFormsKey = 'profile_show_other_forms';
const notifyNewPokemonKey = 'profile_notify_new_pokemon';
const notifyAppUpdatesKey = 'profile_notify_app_updates';
const interfaceLanguageKey = 'profile_interface_language';
const gameInfoLanguageKey = 'profile_game_info_language';

ProfileSettings readStoredProfileSettings(SharedPreferences prefs) {
  return ProfileSettings(
    showMegaEvolutions: prefs.getBool(showMegaEvolutionsKey) ?? true,
    showOtherForms: prefs.getBool(showOtherFormsKey) ?? true,
    notifyNewPokemon: prefs.getBool(notifyNewPokemonKey) ?? true,
    notifyAppUpdates: prefs.getBool(notifyAppUpdatesKey) ?? false,
    interfaceLanguage: prefs.getString(interfaceLanguageKey) ?? 'pt-BR',
    gameInfoLanguage: prefs.getString(gameInfoLanguageKey) ?? 'en-US',
  );
}

class ProfileSettingsNotifier extends StateNotifier<ProfileSettings> {
  ProfileSettingsNotifier(super.initial);

  Future<void> _persist(ProfileSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(showMegaEvolutionsKey, settings.showMegaEvolutions);
    await prefs.setBool(showOtherFormsKey, settings.showOtherForms);
    await prefs.setBool(notifyNewPokemonKey, settings.notifyNewPokemon);
    await prefs.setBool(notifyAppUpdatesKey, settings.notifyAppUpdates);
    await prefs.setString(interfaceLanguageKey, settings.interfaceLanguage);
    await prefs.setString(gameInfoLanguageKey, settings.gameInfoLanguage);
  }

  Future<void> setShowMegaEvolutions(bool value) async {
    state = state.copyWith(showMegaEvolutions: value);
    await _persist(state);
  }

  Future<void> setShowOtherForms(bool value) async {
    state = state.copyWith(showOtherForms: value);
    await _persist(state);
  }

  Future<void> setNotifyNewPokemon(bool value) async {
    state = state.copyWith(notifyNewPokemon: value);
    await _persist(state);
  }

  Future<void> setNotifyAppUpdates(bool value) async {
    state = state.copyWith(notifyAppUpdates: value);
    await _persist(state);
  }

  Future<void> toggleInterfaceLanguage() async {
    final next = state.interfaceLanguage == 'pt-BR' ? 'en-US' : 'pt-BR';
    state = state.copyWith(interfaceLanguage: next);
    await _persist(state);
  }

  Future<void> toggleGameInfoLanguage() async {
    final next = state.gameInfoLanguage == 'pt-BR' ? 'en-US' : 'pt-BR';
    state = state.copyWith(gameInfoLanguage: next);
    await _persist(state);
  }
}

final profileSettingsProvider =
    StateNotifierProvider<ProfileSettingsNotifier, ProfileSettings>((ref) {
      return ProfileSettingsNotifier(const ProfileSettings());
    });
