import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/region_card_assets.dart';

void main() {
  test('curated regions are Kanto through Paldea', () {
    expect(RegionCardAssets.curated, hasLength(10));
    expect(RegionCardAssets.curated.first.apiName, 'kanto');
    expect(RegionCardAssets.curated.last.apiName, 'paldea');
    expect(RegionCardAssets.curated.first.starterIds, [1, 4, 7]);
    expect(RegionCardAssets.forApiName('hisui')?.starterIds, [
      10244,
      10233,
      10236,
    ]);
    expect(RegionCardAssets.curated.last.starterIds, [906, 909, 912]);
  });

  test('forApiName returns matching region', () {
    final kanto = RegionCardAssets.forApiName('kanto');
    expect(kanto?.displayName, 'Kanto');
    expect(kanto?.generationNumber, 1);
    expect(RegionCardAssets.forApiName('unknown'), isNull);
  });
}
