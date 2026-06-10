import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/region_labels.dart';

void main() {
  test('label returns mapped region names', () {
    expect(RegionLabels.label('kanto'), 'Kanto');
    expect(RegionLabels.label('paldea'), 'Paldea');
  });

  test('label capitalizes unknown regions', () {
    expect(RegionLabels.label('unknown'), 'Unknown');
  });
}
