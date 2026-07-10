import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/game_text_resolver_provider.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/resolved_game_text.dart';
import 'package:riverpod/misc.dart';

typedef CategoryInput = ({
  List<dynamic> generaEntries,
  String targetLang,
});

final FutureProviderFamily<ResolvedGameText?, CategoryInput>
localizedCategoryProvider =
    FutureProvider.family<ResolvedGameText?, CategoryInput>((
      ref,
      input,
    ) async {
      if (input.generaEntries.isEmpty) return null;

      final resolver = ref.watch(gameTextResolverProvider);
      return resolver.resolveFromEntries(
        entries: input.generaEntries,
        kind: GameTextKind.name,
        targetLang: input.targetLang,
        textKey: 'genus',
      );
    });
