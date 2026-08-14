import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/reviews/presentation/providers/app_review_provider.dart';

/// Toggles a favorite for an authenticated user and may request a review.
void toggleAuthenticatedFavorite(WidgetRef ref, {required int pokemonId}) {
  final willFavorite = !ref.read(favoritesProvider).contains(pokemonId);
  unawaited(ref.read(favoritesProvider.notifier).toggle(pokemonId));
  ref
      .read(appAnalyticsProvider)
      .favoriteToggled(pokemonId: pokemonId, isFavorite: willFavorite);
  if (willFavorite) {
    unawaited(
      ref.read(appReviewControllerProvider).maybeRequestAfterFavorite(),
    );
  }
}
