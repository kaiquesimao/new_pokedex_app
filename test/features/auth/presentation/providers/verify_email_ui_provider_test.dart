import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/verify_email_ui_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VerifyEmailUiNotifier', () {
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

    Future<void> seedCompleteRegisterFlow() async {
      final register = container.read(registerFlowProvider.notifier)
        ..submitEmail('ash@pokemon.com');
      await register.submitPassword('senha123');
      await register.submitName('Ash');
    }

    test(
      'completeRegistration sets error when verifyOtp returns false',
      () async {
        await seedCompleteRegisterFlow();
        final sub = container.listen(
          verifyEmailUiProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sub.close);

        final notifier = container.read(verifyEmailUiProvider.notifier);
        final success = await notifier.completeRegistration(otpCode: '123');

        expect(success, isFalse);
        final state = container.read(verifyEmailUiProvider);
        expect(state.error, 'Código inválido. Tente novamente.');
        expect(state.loading, isFalse);
      },
    );
  });
}
