import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('readStoredProfileSettings uses system locale when empty', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final settings = readStoredProfileSettings(prefs);

    expect(settings.notifyNewPokemon, isTrue);
    expect(settings.notifyAppUpdates, isFalse);
    expect(settings.appLanguage, anyOf('pt-BR', 'en-US'));
  });

  test('migrates legacy interfaceLanguageKey when explicitly en-US', () async {
    SharedPreferences.setMockInitialValues({
      interfaceLanguageKey: 'en-US',
    });
    final prefs = await SharedPreferences.getInstance();

    expect(readStoredProfileSettings(prefs).appLanguage, 'en-US');
  });

  test('ignores legacy pt-BR default and uses system locale', () async {
    SharedPreferences.setMockInitialValues({
      interfaceLanguageKey: 'pt-BR',
    });
    final prefs = await SharedPreferences.getInstance();

    expect(
      readStoredProfileSettings(prefs).appLanguage,
      anyOf('pt-BR', 'en-US'),
    );
  });

  test(
    'seedInitialAppLanguage persists detected language on first launch',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await seedInitialAppLanguage(prefs);

      expect(prefs.getString(appLanguageKey), anyOf('pt-BR', 'en-US'));
      expect(
        readStoredProfileSettings(prefs).appLanguage,
        prefs.getString(appLanguageKey),
      );
    },
  );

  test('seedInitialAppLanguage is a no-op when already stored', () async {
    SharedPreferences.setMockInitialValues({
      appLanguageKey: 'en-US',
    });
    final prefs = await SharedPreferences.getInstance();

    await seedInitialAppLanguage(prefs);

    expect(prefs.getString(appLanguageKey), 'en-US');
  });

  test('readStoredProfileSettings returns persisted values', () async {
    SharedPreferences.setMockInitialValues({
      notifyNewPokemonKey: false,
      notifyAppUpdatesKey: true,
      appLanguageKey: 'pt-BR',
    });
    final prefs = await SharedPreferences.getInstance();

    final settings = readStoredProfileSettings(prefs);

    expect(settings.notifyNewPokemon, isFalse);
    expect(settings.notifyAppUpdates, isTrue);
    expect(settings.appLanguage, 'pt-BR');
  });

  test('ignores leftover mega/other form preference keys', () async {
    SharedPreferences.setMockInitialValues({
      'profile_show_mega_evolutions': false,
      'profile_show_other_forms': false,
      appLanguageKey: 'en-US',
    });
    final prefs = await SharedPreferences.getInstance();

    final settings = readStoredProfileSettings(prefs);

    expect(settings.appLanguage, 'en-US');
    expect(settings.notifyNewPokemon, isTrue);
  });
}
