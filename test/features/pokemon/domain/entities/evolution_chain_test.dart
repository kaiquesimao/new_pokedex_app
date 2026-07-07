import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/l10n/generated/app_localizations_pt.dart';

void main() {
  test('displayLabel uses pre-resolved item display name', () {
    const trigger = EvolutionTriggerInfo(
      itemSlug: 'fire-stone',
      itemDisplayName: 'Pedra de Fogo',
    );
    final l10n = AppLocalizationsPt();

    expect(trigger.displayLabel(l10n), 'Pedra de Fogo');
  });

  test('displayLabel uses pre-resolved held item display name', () {
    const trigger = EvolutionTriggerInfo(
      heldItemSlug: 'metal-coat',
      heldItemDisplayName: 'Capa Metálica',
    );
    final l10n = AppLocalizationsPt();

    expect(trigger.displayLabel(l10n), 'Segurando Capa Metálica');
  });
}
