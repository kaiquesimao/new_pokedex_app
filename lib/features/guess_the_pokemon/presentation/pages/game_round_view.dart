import 'dart:async';

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
  final bool spriteReady = false,
  final int? selectedOptionId,
  final bool? lastAnswerCorrect,
  final String? revealedPokemonName,
  final String? revealedSpriteUrl,
  final int? secondsRemaining,
  final bool timedOut = false,
  final Object? error,
  final VoidCallback? onRetry,
  final VoidCallback? onSpriteReady,
}) extends StatelessWidget {
  static const answerDurationSeconds = 5;
  static const _motion = Duration(milliseconds: 260);
  static const _revealMotion = Duration(milliseconds: 340);

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
    final roundArmed = spriteReady || isAnswering;
    final roundKey =
        localRound?.sequenceNumber ?? remoteRound?.roundIndex ?? score;

    if (options.isEmpty || spriteUrl == null) {
      return Center(child: Text(l10n.gameError));
    }

    final silhouetteColor = isDark
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF1B1B1B);
    final cardColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainerLowest;

    // Fit the full round in the viewport: no scroll for a timed guessing game.
    // Bottom shell padding already clears the floating nav; keep this compact.
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedSwitcher(
                duration: _motion,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: Text(
                  l10n.gameScore(score),
                  key: ValueKey(score),
                ),
              ),
            ),
            AnimatedSize(
              duration: _motion,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: secondsRemaining != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Semantics(
                        liveRegion: !isAnswering,
                        label: l10n.gameTimerSemantics(secondsRemaining!),
                        child: Opacity(
                          opacity: isAnswering
                              ? 0.55
                              : spriteReady
                              ? 1
                              : 0.45,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: _RoundTimerBar(
                                  roundKey: roundKey,
                                  frozen: !roundArmed || isAnswering,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 160),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  '$secondsRemaining',
                                  key: ValueKey(secondsRemaining),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: secondsRemaining! <= 2
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(l10n.gameError),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: Text(l10n.gameRetryButton),
                ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final available = constraints.maxWidth < constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;
                  final side = (available - 24).clamp(96.0, 200.0);
                  return Center(
                    child: Card(
                      color: cardColor,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _RevealSprite(
                          key: ValueKey('sprite-$roundKey'),
                          imageUrl: spriteUrl,
                          size: side,
                          revealed: showReveal,
                          silhouetteColor: silhouetteColor,
                          semanticLabel: showReveal
                              ? (revealedPokemonName ?? l10n.gameTitle)
                              : l10n.gameTitle,
                          onLoaded: isAnswering ? null : onSpriteReady,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedSize(
              duration: _motion,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: showReveal
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AnimatedSwitcher(
                        duration: _motion,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Column(
                          key: ValueKey(
                            '${timedOut}_${lastAnswerCorrect}_$revealedPokemonName',
                          ),
                          children: [
                            Text(
                              timedOut
                                  ? l10n.gameAnswerTimeout
                                  : lastAnswerCorrect!
                                  ? l10n.gameAnswerCorrect
                                  : l10n.gameAnswerWrong,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: lastAnswerCorrect!
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (revealedPokemonName != null &&
                                revealedPokemonName!.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                l10n.gameCorrectWas(revealedPokemonName!),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                // Always 2 columns so four answers fit without vertical scroll.
                final optionWidth = (constraints.maxWidth - 10) / 2;
                return AnimatedSwitcher(
                  duration: _revealMotion,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        ?currentChild,
                      ],
                    );
                  },
                  child: Wrap(
                    key: ValueKey('options-$roundKey'),
                    spacing: 10,
                    runSpacing: 10,
                    children: options.map((option) {
                      final isSelected = selectedOptionId == option.speciesId;
                      final isCorrectOption =
                          showReveal &&
                          revealedPokemonName != null &&
                          option.name == revealedPokemonName;
                      return SizedBox(
                        width: optionWidth,
                        child: Opacity(
                          opacity: roundArmed || showReveal ? 1 : 0.5,
                          child: GameOptionButton(
                            name: option.name,
                            selected: isSelected,
                            correct: showReveal ? isCorrectOption : null,
                            onPressed: isAnswering || !spriteReady
                                ? null
                                : () => onAnswer(option.speciesId),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
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

class _RoundTimerBar extends StatefulWidget {
  const new({
    required this.roundKey,
    required this.frozen,
    required this.theme,
  });

  final Object roundKey;
  final bool frozen;
  final ThemeData theme;

  @override
  State<_RoundTimerBar> createState() => _RoundTimerBarState();
}

class _RoundTimerBarState extends State<_RoundTimerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: GameRoundView.answerDurationSeconds),
      value: 1,
    );
    if (!widget.frozen) {
      _controller.animateTo(0);
    }
  }

  @override
  void didUpdateWidget(covariant _RoundTimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.roundKey != oldWidget.roundKey) {
      _controller.duration = const Duration(
        seconds: GameRoundView.answerDurationSeconds,
      );
      _controller.value = 1;
      if (!widget.frozen) {
        _controller.animateTo(0);
      }
      return;
    }
    if (widget.frozen && !oldWidget.frozen) {
      _controller.stop();
    } else if (!widget.frozen && oldWidget.frozen) {
      _controller.animateTo(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = _controller.value.clamp(0.0, 1.0);
        final urgent = value <= 0.4;
        return LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: widget.theme.colorScheme.surfaceContainerHighest,
          color: urgent
              ? widget.theme.colorScheme.error
              : widget.theme.colorScheme.primary,
        );
      },
    );
  }
}

class _RevealSprite extends StatelessWidget {
  const new({
    required this.imageUrl,
    required this.size,
    required this.revealed,
    required this.silhouetteColor,
    required this.semanticLabel,
    super.key,
    this.onLoaded,
  });

  final String imageUrl;
  final double size;
  final bool revealed;
  final Color silhouetteColor;
  final String semanticLabel;
  final VoidCallback? onLoaded;

  static const _duration = Duration(milliseconds: 340);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: revealed ? 0 : 1),
      duration: _duration,
      curve: Curves.easeOutCubic,
      builder: (context, silhouetteAmount, _) {
        final coloredOpacity = (1 - silhouetteAmount).clamp(0.0, 1.0);
        final silhouetteOpacity = silhouetteAmount.clamp(0.0, 1.0);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (coloredOpacity > 0.01)
                Opacity(
                  opacity: coloredOpacity,
                  child: _sprite(notifyLoaded: false),
                ),
              if (silhouetteOpacity > 0.01)
                Opacity(
                  opacity: silhouetteOpacity,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      silhouetteColor,
                      BlendMode.srcIn,
                    ),
                    child: _sprite(notifyLoaded: !revealed),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _sprite({required bool notifyLoaded}) {
    return PokemonSpriteImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      maxCachePixels: 768,
      semanticLabel: semanticLabel,
      onLoaded: notifyLoaded ? onLoaded : null,
    );
  }
}

class const _RoundOption({
  required final int speciesId,
  required final String name,
});
