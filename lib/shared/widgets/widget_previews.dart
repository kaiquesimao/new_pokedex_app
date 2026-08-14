import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/theme/app_widget_preview.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_icon.dart';
import 'package:pokedex_app/shared/widgets/sort_option_chip.dart';

@Preview(
  name: 'Fire type chip',
  group: 'Types',
  size: Size(220, 72),
  brightness: Brightness.light,
  theme: appPreviewTheme,
  localizations: appPreviewLocalizations,
)
@Preview(
  name: 'Fire type chip',
  group: 'Types',
  size: Size(220, 72),
  brightness: Brightness.dark,
  theme: appPreviewTheme,
  localizations: appPreviewLocalizations,
)
Widget fireTypeChipPreview() {
  return const Center(
    child: PokemonTypeChip(type: PokemonType.fire, selected: true),
  );
}

@Preview(
  name: 'Water type icon',
  group: 'Types',
  size: Size(64, 64),
  brightness: Brightness.light,
  theme: appPreviewTheme,
)
Widget waterTypeIconPreview() {
  return Center(
    child: PokemonTypeIcon(
      assetPath: PokemonType.water.assetPath,
      size: 32,
      color: const Color(0xFF6390F0),
    ),
  );
}

@Preview(
  name: 'Sort option — selected',
  group: 'Filters',
  size: Size(200, 72),
  brightness: Brightness.light,
  theme: appPreviewTheme,
)
Widget sortOptionChipSelectedPreview() {
  return const Center(
    child: SortOptionChip(
      label: 'Name',
      selected: true,
      onTap: _previewNoop,
    ),
  );
}

void _previewNoop() {}
