import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/change_password_flow_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChangePasswordFlowNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'mock_auth_session': true,
        'mock_auth_email': 'ash@pokemon.com',
        'mock_auth_name': 'Ash',
        'mock_auth_password': 'senha123',
      });
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
          authProvider.overrideWithBuild(
            (ref, notifier) => const AuthState(
              isInitialized: true,
              isAuthenticated: true,
              email: 'ash@pokemon.com',
              displayName: 'Ash',
            ),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('submitCurrent rejects empty password', () async {
      final notifier = container.read(changePasswordFlowProvider.notifier);

      await notifier.submitCurrent('');

      expect(
        container.read(changePasswordFlowProvider).error,
        'Informe sua senha atual',
      );
      expect(container.read(changePasswordFlowProvider).loading, isFalse);
    });

    test('submitCurrent advances to newPassword on valid password', () async {
      final notifier = container.read(changePasswordFlowProvider.notifier);

      await notifier.submitCurrent('senha123');

      final state = container.read(changePasswordFlowProvider);
      expect(state.step, ChangePasswordStep.newPassword);
      expect(state.verifiedCurrentPassword, 'senha123');
      expect(state.error, isNull);
      expect(state.loading, isFalse);
    });

    test('submitNew rejects weak password', () {
      container.read(changePasswordFlowProvider.notifier).submitNew('123');

      final state = container.read(changePasswordFlowProvider);
      expect(state.error, isNotNull);
      expect(state.step, ChangePasswordStep.current);
    });

    test('goBackStep navigates backward', () async {
      final notifier = container.read(changePasswordFlowProvider.notifier);

      await notifier.submitCurrent('senha123');
      expect(
        container.read(changePasswordFlowProvider).step,
        ChangePasswordStep.newPassword,
      );

      notifier.goBackStep();
      expect(
        container.read(changePasswordFlowProvider).step,
        ChangePasswordStep.current,
      );

      await notifier.submitCurrent('senha123');
      notifier.submitNew('nova123');
      expect(
        container.read(changePasswordFlowProvider).step,
        ChangePasswordStep.confirm,
      );

      notifier.goBackStep();
      expect(
        container.read(changePasswordFlowProvider).step,
        ChangePasswordStep.newPassword,
      );
    });
  });
}
