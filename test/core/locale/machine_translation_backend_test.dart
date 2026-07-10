import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/machine_translation_backend.dart';

void main() {
  group('InMemoryMachineTranslationBackend', () {
    test('returns cached result on second call', () async {
      var calls = 0;
      final backend = InMemoryMachineTranslationBackend(
        translateFn: (text, from, to) async {
          calls++;
          return 'traduzido';
        },
      );

      final first = await backend.translate(
        text: 'hello',
        fromLang: 'en',
        toLang: 'pt-br',
      );
      final second = await backend.translate(
        text: 'hello',
        fromLang: 'en',
        toLang: 'pt-br',
      );

      expect(first, 'traduzido');
      expect(second, 'traduzido');
      expect(calls, 1);
    });

    test('returns null when translateFn throws', () async {
      final backend = InMemoryMachineTranslationBackend(
        translateFn: (_, _, _) async => throw Exception('offline'),
      );

      final result = await backend.translate(
        text: 'hello',
        fromLang: 'en',
        toLang: 'pt-br',
      );

      expect(result, isNull);
    });

    test('skips translation when langs match', () async {
      var called = false;
      final backend = InMemoryMachineTranslationBackend(
        translateFn: (_, _, _) async {
          called = true;
          return 'x';
        },
      );

      final result = await backend.translate(
        text: 'hello',
        fromLang: 'en',
        toLang: 'en',
      );

      expect(result, 'hello');
      expect(called, isFalse);
    });
  });
}
