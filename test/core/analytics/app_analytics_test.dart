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
          analytics
            ..pokemonViewed(pokemonId: 1, name: 'Bulbasaur')
            ..filterType(typeName: 'Grama')
            ..sortChanged(sortLabel: 'A-Z')
            ..favoriteToggled(pokemonId: 1, isFavorite: true)
            ..regionOpened(regionName: 'Kanto');
        },
        returnsNormally,
      );
    });
  });
}
