import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart'
    show localFavoritesRepositoryProvider;

/// Clears user-scoped local data when the session ends or the user changes.
final authSessionEffectsProvider = Provider<void>((ref) {
  ref.listen<AuthState>(authProvider, (previous, next) {
    final wasAuthenticated = previous?.isAuthenticated ?? false;
    final isAuthenticated = next.isAuthenticated;
    final previousUid = previous?.uid;
    final nextUid = next.uid;

    final sessionEnded = wasAuthenticated && !isAuthenticated;
    final userChanged =
        wasAuthenticated && isAuthenticated && previousUid != nextUid;

    if (!sessionEnded && !userChanged) return;

    unawaited(ref.read(localFavoritesRepositoryProvider).replaceAll({}));
    ref.read(registerFlowProvider.notifier).reset();
  });
});
