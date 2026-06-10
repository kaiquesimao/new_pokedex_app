import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('readStoredProfileSettings returns defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final settings = readStoredProfileSettings(prefs);

    expect(settings.showMegaEvolutions, isTrue);
    expect(settings.showOtherForms, isTrue);
    expect(settings.notifyNewPokemon, isTrue);
    expect(settings.notifyAppUpdates, isFalse);
    expect(settings.interfaceLanguage, 'pt-BR');
    expect(settings.gameInfoLanguage, 'en-US');
  });

  test('readStoredProfileSettings returns persisted values', () async {
    SharedPreferences.setMockInitialValues({
      showMegaEvolutionsKey: false,
      showOtherFormsKey: false,
      notifyNewPokemonKey: false,
      notifyAppUpdatesKey: true,
      interfaceLanguageKey: 'en-US',
      gameInfoLanguageKey: 'pt-BR',
    });
    final prefs = await SharedPreferences.getInstance();

    final settings = readStoredProfileSettings(prefs);

    expect(settings.showMegaEvolutions, isFalse);
    expect(settings.showOtherForms, isFalse);
    expect(settings.notifyNewPokemon, isFalse);
    expect(settings.notifyAppUpdates, isTrue);
    expect(settings.interfaceLanguage, 'en-US');
    expect(settings.gameInfoLanguage, 'pt-BR');
  });
}
