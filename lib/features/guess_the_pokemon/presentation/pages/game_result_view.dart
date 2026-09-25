import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

/// Shows the score returned by the game controller and its publication state.
class const GameResultView({
  required final Future<void> Function() onPlayAgain,
  required final VoidCallback onLeaderboard,
  required final int score,
  required final int bestScore,
  required final bool canPublish,
  required final PublicationState publicationState,
  super.key,
  final Future<void> Function()? onPublish,
  final GameRound? localRound,
  final GameRoundModel? remoteRound,
  final String? revealedPokemonName,
  final String? revealedSpriteUrl,
  final bool? lastAnswerCorrect,
  final bool timedOut = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rawSprite =
        revealedSpriteUrl ??
        localRound?.correctAnswer.spriteUrl ??
        remoteRound?.silhouetteUrl;
    final speciesId =
        localRound?.correctAnswer.speciesId ??
        PokemonSpriteUrls.idFromSpriteUrl(rawSprite ?? '');
    final spriteUrl = rawSprite == null
        ? null
        : PokemonSpriteUrls.highQualitySpriteUrl(
            rawSprite,
            speciesId: speciesId,
          );
    final pokemonName =
        revealedPokemonName ?? localRound?.correctAnswer.name ?? '';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Text(
                  l10n.gameResultTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                if (spriteUrl != null) ...[
                  const SizedBox(height: 16),
                  PokemonSpriteImage(
                    imageUrl: spriteUrl,
                    width: 180,
                    height: 180,
                    maxCachePixels: 768,
                    semanticLabel: pokemonName.isEmpty
                        ? l10n.gameResultTitle
                        : pokemonName,
                  ),
                ],
                if (pokemonName.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.gameCorrectWas(pokemonName),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (lastAnswerCorrect != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    timedOut
                        ? l10n.gameAnswerTimeout
                        : lastAnswerCorrect!
                        ? l10n.gameAnswerCorrect
                        : l10n.gameAnswerWrong,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: lastAnswerCorrect!
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  l10n.gameScore(score),
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(l10n.gameBestScore(bestScore)),
                const SizedBox(height: 24),
                if (publicationState == PublicationState.published)
                  Text(l10n.gamePublishedMessage)
                else if (publicationState == PublicationState.pending)
                  _PublicationProgress(message: l10n.gamePublicationPending)
                else if (publicationState == PublicationState.failed) ...[
                  Text(
                    l10n.gamePublicationFailed,
                    textAlign: TextAlign.center,
                  ),
                  if (onPublish != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: onPublish,
                      child: Text(l10n.gameRetryPublicationButton),
                    ),
                  ],
                ] else if (!canPublish)
                  Text(
                    l10n.gamePublicOnlyMessage,
                    textAlign: TextAlign.center,
                  )
                else if (onPublish != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: onPublish,
                    child: Text(l10n.gamePublishButton),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onPlayAgain,
                  child: Text(l10n.gamePlayAgainButton),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                  onPressed: onLeaderboard,
                  child: Text(l10n.gameLeaderboardButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class const _PublicationProgress({required final String message})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Flexible(child: Text(message, textAlign: TextAlign.center)),
      ],
    );
  }
}
