import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';

void main() {
  group('cachePixelSize', () {
    test('scales with device pixel ratio', () {
      expect(cachePixelSize(72, 1), 72);
      expect(cachePixelSize(72, 2), 144);
      expect(cachePixelSize(72, 3), 216);
    });

    test('respects maxPixels cap', () {
      expect(cachePixelSize(72, 3, maxPixels: 144), 144);
      expect(cachePixelSize(140, 3, maxPixels: 420), 420);
    });

    test('returns null for non-positive logical size', () {
      expect(cachePixelSize(0, 3), isNull);
      expect(cachePixelSize(-1, 3), isNull);
    });

    test('clamps to at least 1 pixel', () {
      expect(cachePixelSize(0.1, 1), 1);
    });
  });
}
