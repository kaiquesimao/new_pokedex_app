import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RegisterFlowNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('submitEmail rejects invalid email', () {
      container.read(registerFlowProvider.notifier).submitEmail('invalid');

      final state = container.read(registerFlowProvider);
      expect(state.error, 'Informe um e-mail válido');
      expect(state.step, RegisterStep.email);
      expect(state.email, isEmpty);
    });

    test('submitEmail advances to password step with email stored', () {
      container
          .read(registerFlowProvider.notifier)
          .submitEmail('ash@pokemon.com');

      final state = container.read(registerFlowProvider);
      expect(state.error, isNull);
      expect(state.step, RegisterStep.password);
      expect(state.email, 'ash@pokemon.com');
    });

    test('submitPassword advances to name step with password stored', () async {
      final notifier = container.read(registerFlowProvider.notifier)
        ..submitEmail('ash@pokemon.com');
      await notifier.submitPassword('senha123');

      final state = container.read(registerFlowProvider);
      expect(state.error, isNull);
      expect(state.step, RegisterStep.name);
      expect(state.password, 'senha123');
      expect(state.name, isEmpty);
    });

    test('submitName rejects empty name', () async {
      final notifier = container.read(registerFlowProvider.notifier)
        ..submitEmail('ash@pokemon.com')
        ..submitPassword('senha123');
      await notifier.submitName('   ');

      final state = container.read(registerFlowProvider);
      expect(state.error, 'Informe seu nome');
      expect(state.step, RegisterStep.name);
      expect(state.name, isEmpty);
    });

    test('goBackStep from password returns to email', () async {
      final notifier = container.read(registerFlowProvider.notifier)
        ..submitEmail('ash@pokemon.com');
      await notifier.goBackStep();

      final state = container.read(registerFlowProvider);
      expect(state.step, RegisterStep.email);
      expect(state.error, isNull);
    });
  });
}
