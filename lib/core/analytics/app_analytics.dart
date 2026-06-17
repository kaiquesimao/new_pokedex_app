import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
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
  FirebaseAppAnalytics(this._analytics, this._connectivity);

  final FirebaseAnalytics _analytics;
  final ConnectivityService _connectivity;

  void _logEvent({required String name, Map<String, Object>? parameters}) {
    if (!_connectivity.isOnline) return;
    unawaited(_analytics.logEvent(name: name, parameters: parameters));
  }

  @override
  void pokemonViewed({required int pokemonId, required String name}) {
    _logEvent(
      name: 'pokemon_viewed',
      parameters: {'pokemon_id': pokemonId, 'name': name},
    );
  }

  @override
  void filterType({String? typeName}) {
    _logEvent(name: 'filter_type', parameters: {'type': typeName ?? 'todos'});
  }

  @override
  void sortChanged({required String sortLabel}) {
    _logEvent(name: 'sort_changed', parameters: {'sort': sortLabel});
  }

  @override
  void favoriteToggled({required int pokemonId, required bool isFavorite}) {
    _logEvent(
      name: 'favorite_toggled',
      parameters: {
        'pokemon_id': pokemonId,
        'is_favorite': isFavorite ? 'true' : 'false',
      },
    );
  }

  @override
  void regionOpened({required String regionName}) {
    _logEvent(name: 'region_opened', parameters: {'region': regionName});
  }
}

final appAnalyticsProvider = Provider<AppAnalytics>((ref) {
  final bootstrap = ref.watch(firebaseBootstrapProvider);
  if (bootstrap.isAvailable) {
    return FirebaseAppAnalytics(
      FirebaseAnalytics.instance,
      ref.watch(connectivityServiceProvider),
    );
  }
  return const NoOpAppAnalytics();
});
