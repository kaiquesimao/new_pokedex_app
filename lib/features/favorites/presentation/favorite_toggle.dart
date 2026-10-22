import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';
import 'package:pokedex_app/core/support/support_prompt_controller.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/reviews/presentation/providers/app_review_provider.dart';

/// Toggles a favorite for an authenticated user and may request a review /
/// Ko-fi support prompt (2nd favorite).
void toggleAuthenticatedFavorite(
  WidgetRef ref, {
  required int pokemonId,
  BuildContext? context,
}) {
  final willFavorite = !ref.read(favoritesProvider).contains(pokemonId);
  final favoriteCountAfterAdd = ref.read(favoritesProvider).length + 1;
  unawaited(ref.read(favoritesProvider.notifier).toggle(pokemonId));
  ref
      .read(appAnalyticsProvider)
      .favoriteToggled(pokemonId: pokemonId, isFavorite: willFavorite);
  if (willFavorite) {
    unawaited(
      ref.read(appReviewControllerProvider).maybeRequestAfterFavorite(),
    );
    if (context != null) {
      scheduleSupportPrompt(
        () => ref
            .read(supportPromptControllerProvider)
            .maybeAfterSecondFavorite(
              context,
              favoriteCountAfterAdd: favoriteCountAfterAdd,
            ),
      );
    }
  }
}
