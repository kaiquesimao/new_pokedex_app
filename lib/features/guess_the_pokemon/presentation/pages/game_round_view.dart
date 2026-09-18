import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/widgets/game_option_button.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

/// Displays one controller-owned round without deciding its outcome.
class const GameRoundView({
  required this.onAnswer,
  super.key,
  this.localRound,
  this.remoteRound,
  this.score = 0,
  this.isAnswering = false,
  this.error,
  this.onRetry,
}) extends StatelessWidget {
  final GameRound? localRound;
  final GameRoundModel? remoteRound;
  final int score;
  final bool isAnswering;
  final Object? error;
  final VoidCallback? onRetry;
  final Future<void> Function(int optionId) onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = _options(l10n);
    final spriteUrl = localRound?.correctAnswer.spriteUrl ?? remoteRound?.silhouetteUrl;

     if (options.isEmpty || spriteUrl == null) {
       return Center(child: Text(l10n.gameError));
     }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(l10n.gameScore(score)),
          ),
          const SizedBox(height: 8),
           Text(
             l10n.gameRoundPrompt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
           ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(l10n.gameError),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text(l10n.gameRetryButton)),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: PokemonSpriteImage(
                  imageUrl: spriteUrl,
                  width: 220,
                  height: 220,
                  semanticLabel: l10n.gameRoundPrompt,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 2 : 1;
              final optionWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: options.map((option) {
                  return SizedBox(
                    width: optionWidth,
                    child: GameOptionButton(
                      name: option.name,
                      onPressed: isAnswering
                          ? null
                          : () => onAnswer(option.speciesId),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<_RoundOption> _options(AppLocalizations l10n) {
    if (localRound != null) {
      return localRound!.options
          .map(
            (option) => _RoundOption(
              speciesId: option.speciesId,
              name: option.name,
            ),
          )
          .toList();
    }
    return remoteRound?.options
            .map(
              (option) => _RoundOption(
                speciesId: option.id,
                name: option.name.isEmpty
                    ? l10n.gamePokemonNumber(option.id)
                    : option.name,
              ),
            )
            .toList() ??
        const [];
  }

}

class const _RoundOption({required this.speciesId, required this.name}) {
  final int speciesId;
  final String name;
}
