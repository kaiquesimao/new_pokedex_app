import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart'
    show localFavoritesRepositoryProvider;
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/guess_the_pokemon_providers.dart';

/// Clears user-scoped local data when the session ends or the user changes.
/// Also keeps the trainer name permanently public on the ranking.
final authSessionEffectsProvider = Provider<void>((ref) {
  ref.listen<AuthState>(authProvider, (previous, next) {
    final wasAuthenticated = previous?.isAuthenticated ?? false;
    final isAuthenticated = next.isAuthenticated;
    final previousUid = previous?.uid;
    final nextUid = next.uid;

    final sessionEnded = wasAuthenticated && !isAuthenticated;
    final userChanged =
        wasAuthenticated && isAuthenticated && previousUid != nextUid;
    final signedIn = !wasAuthenticated && isAuthenticated;

    if (sessionEnded || userChanged) {
      unawaited(ref.read(localFavoritesRepositoryProvider).replaceAll({}));
      ref.invalidate(guessThePokemonControllerProvider);
      ref.invalidate(guessThePokemonRepositoryProvider);
      ref.read(registerFlowProvider.notifier).reset();
    }

    if (signedIn || (isAuthenticated && userChanged)) {
      unawaited(
        ref
            .read(guessThePokemonRepositoryProvider)
            .savePublicProfilePreference(
              value: true,
              displayName: next.displayName,
            ),
      );
    }
  });
});
