import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/pokemon/presentation/pokemon_detail_preview.dart';

void openPokemonDetail(BuildContext context, PokemonDetailPreview preview) {
  unawaited(context.push('/pokemon/${preview.id}', extra: preview));
}
