import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/game_text_resolver_provider.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/resolved_game_text.dart';
import 'package:riverpod/misc.dart';

typedef AbilityInput = ({
  String slug,
  String targetLang,
});

final FutureProviderFamily<ResolvedGameText, AbilityInput>
localizedAbilityProvider = FutureProvider.family<ResolvedGameText, AbilityInput>(
  (ref, input) async {
    final resolver = ref.watch(gameTextResolverProvider);
    return resolver.resolveResource(
      resource: ApiLoadTarget.ability,
      slug: input.slug,
      kind: GameTextKind.name,
      targetLang: input.targetLang,
    );
  },
);
