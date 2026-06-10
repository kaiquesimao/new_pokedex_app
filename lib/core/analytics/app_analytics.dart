import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';

/// Analytics facade. Uses Firebase when bootstrap is available.
abstract class AppAnalytics {
  void pokemonViewed({required int pokemonId, required String name});

  void filterType({String? typeName});

  void sortChanged({required String sortLabel});

  void favoriteToggled({required int pokemonId, required bool isFavorite});

  void regionOpened({required String regionName});
}

class NoOpAppAnalytics implements AppAnalytics {
  const NoOpAppAnalytics();

  @override
  void pokemonViewed({required int pokemonId, required String name}) {
    _log('pokemon_viewed', {'pokemon_id': pokemonId, 'name': name});
  }

  @override
  void filterType({String? typeName}) {
    _log('filter_type', {'type': typeName ?? 'todos'});
  }

  @override
  void sortChanged({required String sortLabel}) {
    _log('sort_changed', {'sort': sortLabel});
  }

  @override
  void favoriteToggled({required int pokemonId, required bool isFavorite}) {
    _log('favorite_toggled', {
      'pokemon_id': pokemonId,
      'is_favorite': isFavorite,
    });
  }

  @override
  void regionOpened({required String regionName}) {
    _log('region_opened', {'region': regionName});
  }

  void _log(String event, Map<String, Object?> params) {
    if (kDebugMode) {
      debugPrint('[Analytics] $event $params');
    }
  }
}

class FirebaseAppAnalytics implements AppAnalytics {
  FirebaseAppAnalytics(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  void pokemonViewed({required int pokemonId, required String name}) {
    _analytics.logEvent(
      name: 'pokemon_viewed',
      parameters: {'pokemon_id': pokemonId, 'name': name},
    );
  }

  @override
  void filterType({String? typeName}) {
    _analytics.logEvent(
      name: 'filter_type',
      parameters: {'type': typeName ?? 'todos'},
    );
  }

  @override
  void sortChanged({required String sortLabel}) {
    _analytics.logEvent(
      name: 'sort_changed',
      parameters: {'sort': sortLabel},
    );
  }

  @override
  void favoriteToggled({required int pokemonId, required bool isFavorite}) {
    _analytics.logEvent(
      name: 'favorite_toggled',
      parameters: {
        'pokemon_id': pokemonId,
        'is_favorite': isFavorite,
      },
    );
  }

  @override
  void regionOpened({required String regionName}) {
    _analytics.logEvent(
      name: 'region_opened',
      parameters: {'region': regionName},
    );
  }
}

final appAnalyticsProvider = Provider<AppAnalytics>((ref) {
  final bootstrap = ref.watch(firebaseBootstrapProvider);
  if (bootstrap.isAvailable) {
    return FirebaseAppAnalytics(FirebaseAnalytics.instance);
  }
  return const NoOpAppAnalytics();
});
