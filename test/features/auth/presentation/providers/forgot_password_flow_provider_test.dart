import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/forgot_password_flow_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ForgotPasswordFlowNotifier', () {
    late ProviderContainer container;
    late ProviderSubscription<ForgotPasswordFlowState> subscription;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      subscription = container.listen(
        forgotPasswordFlowProvider,
        (_, _) {},
        fireImmediately: true,
      );
    });

    tearDown(() {
      subscription.close();
      container.dispose();
    });

    test('submitEmail rejects invalid email', () async {
      final notifier = container.read(forgotPasswordFlowProvider.notifier);

      await notifier.submitEmail('invalid');

      final state = container.read(forgotPasswordFlowProvider);
      expect(state.error, 'Informe um e-mail válido');
      expect(state.step, ForgotPasswordStep.email);
      expect(state.email, isEmpty);
    });

    test('submitEmail advances to otp step in mock mode', () async {
      final notifier = container.read(forgotPasswordFlowProvider.notifier);

      await notifier.submitEmail('ash@pokemon.com');

      final state = container.read(forgotPasswordFlowProvider);
      expect(state.error, isNull);
      expect(state.step, ForgotPasswordStep.otp);
      expect(state.email, 'ash@pokemon.com');
      expect(state.loading, isFalse);
    });

    test('verifyOtp sets error on invalid code', () async {
      final notifier = container.read(forgotPasswordFlowProvider.notifier);

      await notifier.submitEmail('ash@pokemon.com');
      await notifier.verifyOtp('123');

      final state = container.read(forgotPasswordFlowProvider);
      expect(state.error, 'Código inválido. Tente novamente.');
      expect(state.step, ForgotPasswordStep.otp);
      expect(state.loading, isFalse);
    });

    test('verifyOtp advances to newPassword on valid code', () async {
      final notifier = container.read(forgotPasswordFlowProvider.notifier);

      await notifier.submitEmail('ash@pokemon.com');
      await notifier.verifyOtp('123456');

      final state = container.read(forgotPasswordFlowProvider);
      expect(state.error, isNull);
      expect(state.step, ForgotPasswordStep.newPassword);
      expect(state.loading, isFalse);
    });

    test('submitNewPassword sets error when passwords mismatch', () async {
      final notifier = container.read(forgotPasswordFlowProvider.notifier);

      await notifier.submitEmail('ash@pokemon.com');
      await notifier.verifyOtp('123456');
      await notifier.submitNewPassword(
        password: 'senha123',
        confirm: 'senha456',
      );

      final state = container.read(forgotPasswordFlowProvider);
      expect(state.error, 'As senhas não coincidem');
      expect(state.step, ForgotPasswordStep.newPassword);
      expect(state.loading, isFalse);
    });

    test('goBackStep from otp returns to email', () async {
      final notifier = container.read(forgotPasswordFlowProvider.notifier);

      await notifier.submitEmail('ash@pokemon.com');
      expect(
        container.read(forgotPasswordFlowProvider).step,
        ForgotPasswordStep.otp,
      );

      notifier.goBackStep();

      final state = container.read(forgotPasswordFlowProvider);
      expect(state.step, ForgotPasswordStep.email);
      expect(state.error, isNull);
    });
  });
}
