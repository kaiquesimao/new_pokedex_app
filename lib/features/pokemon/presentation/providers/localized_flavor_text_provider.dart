import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/game_text_resolver_provider.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/resolved_game_text.dart';
import 'package:riverpod/misc.dart';

typedef FlavorTextInput = ({
  List<dynamic> flavorEntries,
  String targetLang,
});

final FutureProviderFamily<ResolvedGameText?, FlavorTextInput>
localizedFlavorTextProvider =
    FutureProvider.family<ResolvedGameText?, FlavorTextInput>((
      ref,
      input,
    ) async {
      if (input.flavorEntries.isEmpty) return null;

      final resolver = ref.watch(gameTextResolverProvider);
      return resolver.resolveFromEntries(
        entries: input.flavorEntries,
        kind: GameTextKind.flavorText,
        targetLang: input.targetLang,
      );
    });
