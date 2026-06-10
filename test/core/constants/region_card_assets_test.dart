import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/region_card_assets.dart';

void main() {
  test('curated regions are Kanto through Galar', () {
    expect(RegionCardAssets.curated, hasLength(8));
    expect(RegionCardAssets.curated.first.apiName, 'kanto');
    expect(RegionCardAssets.curated.last.apiName, 'galar');
    expect(RegionCardAssets.curated.first.starterIds, [1, 4, 7]);
  });

  test('forApiName returns matching region', () {
    final kanto = RegionCardAssets.forApiName('kanto');
    expect(kanto?.displayName, 'Kanto');
    expect(kanto?.generationNumber, 1);
    expect(RegionCardAssets.forApiName('unknown'), isNull);
  });
}
