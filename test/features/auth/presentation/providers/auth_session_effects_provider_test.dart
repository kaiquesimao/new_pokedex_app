import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_session_effects_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('clears local favorites and register draft on sign out', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer.test(
      overrides: [
        firebaseUnavailableOverride,
        sharedPreferencesProvider.overrideWithValue(prefs),
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(
            isInitialized: true,
            isAuthenticated: true,
            uid: 'user-1',
            email: 'ash@pokemon.com',
            displayName: 'Ash',
          ),
        ),
      ],
    );

    container.read(authSessionEffectsProvider);
    container.read(registerFlowProvider.notifier).setEmail('draft@pokemon.com');

    await container.read(localFavoritesRepositoryProvider).toggleFavorite(25);
    expect(
      await container.read(localFavoritesRepositoryProvider).getFavoriteIds(),
      {25},
    );

    await container.read(authProvider.notifier).signOut();
    await Future<void>.delayed(Duration.zero);

    expect(
      await container.read(localFavoritesRepositoryProvider).getFavoriteIds(),
      isEmpty,
    );
    expect(container.read(registerFlowProvider).email, isEmpty);
  });
}
