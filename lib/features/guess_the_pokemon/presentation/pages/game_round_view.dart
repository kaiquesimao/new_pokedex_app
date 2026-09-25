import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/widgets/game_option_button.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

/// Displays one controller-owned round without deciding its outcome.
class const GameRoundView({
  required final Future<void> Function(int optionId) onAnswer,
  super.key,
  final GameRound? localRound,
  final GameRoundModel? remoteRound,
  final int score = 0,
  final bool isAnswering = false,
  final int? selectedOptionId,
  final bool? lastAnswerCorrect,
  final String? revealedPokemonName,
  final String? revealedSpriteUrl,
  final Object? error,
  final VoidCallback? onRetry,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final options = _options(l10n);
    final rawSpriteUrl =
        revealedSpriteUrl ??
        localRound?.correctAnswer.spriteUrl ??
        remoteRound?.silhouetteUrl;
    final speciesId =
        localRound?.correctAnswer.speciesId ??
        PokemonSpriteUrls.idFromSpriteUrl(rawSpriteUrl ?? '');
    final spriteUrl = rawSpriteUrl == null
        ? null
        : PokemonSpriteUrls.highQualitySpriteUrl(
            rawSpriteUrl,
            speciesId: speciesId,
          );
    final showReveal = isAnswering && lastAnswerCorrect != null;

    if (options.isEmpty || spriteUrl == null) {
      return Center(child: Text(l10n.gameError));
    }

    final silhouetteColor = isDark
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF1B1B1B);
    final cardColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainerLowest;

    final sprite = PokemonSpriteImage(
      key: ValueKey('game-sprite-$showReveal-$spriteUrl'),
      imageUrl: spriteUrl,
      width: 220,
      height: 220,
      maxCachePixels: 768,
      semanticLabel: showReveal
          ? (revealedPokemonName ?? l10n.gameTitle)
          : l10n.gameTitle,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(l10n.gameScore(score)),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(l10n.gameError),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text(l10n.gameRetryButton)),
          ],
          const SizedBox(height: 16),
          Card(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: showReveal
                  ? sprite
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        silhouetteColor,
                        BlendMode.srcIn,
                      ),
                      child: sprite,
                    ),
            ),
          ),
          if (showReveal) ...[
            const SizedBox(height: 16),
            Text(
              lastAnswerCorrect!
                  ? l10n.gameAnswerCorrect
                  : l10n.gameAnswerWrong,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: lastAnswerCorrect!
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (revealedPokemonName != null &&
                revealedPokemonName!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.gameCorrectWas(revealedPokemonName!),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ],
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
                  final isSelected = selectedOptionId == option.speciesId;
                  final isCorrectOption =
                      showReveal &&
                      revealedPokemonName != null &&
                      option.name == revealedPokemonName;
                  return SizedBox(
                    width: optionWidth,
                    child: GameOptionButton(
                      name: option.name,
                      selected: isSelected,
                      correct: showReveal ? isCorrectOption : null,
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

class const _RoundOption({required final int speciesId, required final String name});
