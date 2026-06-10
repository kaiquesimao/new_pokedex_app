import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';

void main() {
  group('NoOpAppAnalytics', () {
    late NoOpAppAnalytics analytics;

    setUp(() {
      analytics = const NoOpAppAnalytics();
    });

    test('exposes all event methods without throwing', () {
      expect(
        () {
          analytics.pokemonViewed(pokemonId: 1, name: 'Bulbasaur');
          analytics.filterType(typeName: 'Grama');
          analytics.sortChanged(sortLabel: 'A-Z');
          analytics.favoriteToggled(pokemonId: 1, isFavorite: true);
          analytics.regionOpened(regionName: 'Kanto');
        },
        returnsNormally,
      );
    });
  });
}
