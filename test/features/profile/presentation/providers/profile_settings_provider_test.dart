import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('readStoredProfileSettings uses system locale when empty', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final settings = readStoredProfileSettings(prefs);

    expect(settings.showMegaEvolutions, isTrue);
    expect(settings.showOtherForms, isTrue);
    expect(settings.notifyNewPokemon, isTrue);
    expect(settings.notifyAppUpdates, isFalse);
    expect(settings.appLanguage, anyOf('pt-BR', 'en-US'));
  });

  test('migrates legacy interfaceLanguageKey', () async {
    SharedPreferences.setMockInitialValues({
      interfaceLanguageKey: 'en-US',
    });
    final prefs = await SharedPreferences.getInstance();

    expect(readStoredProfileSettings(prefs).appLanguage, 'en-US');
  });

  test('readStoredProfileSettings returns persisted values', () async {
    SharedPreferences.setMockInitialValues({
      showMegaEvolutionsKey: false,
      showOtherFormsKey: false,
      notifyNewPokemonKey: false,
      notifyAppUpdatesKey: true,
      appLanguageKey: 'pt-BR',
    });
    final prefs = await SharedPreferences.getInstance();

    final settings = readStoredProfileSettings(prefs);

    expect(settings.showMegaEvolutions, isFalse);
    expect(settings.showOtherForms, isFalse);
    expect(settings.notifyNewPokemon, isFalse);
    expect(settings.notifyAppUpdates, isTrue);
    expect(settings.appLanguage, 'pt-BR');
  });
}
