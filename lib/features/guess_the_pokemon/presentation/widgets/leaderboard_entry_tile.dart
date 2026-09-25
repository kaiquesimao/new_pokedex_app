import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class const LeaderboardEntryTile({
  required final int rank,
  required final String playerName,
  required final int score,
  required final bool isCurrentUser,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final name = playerName.trim().isEmpty
        ? l10n.leaderboardAnonymousTrainer
        : playerName;
    final scoreLabel = l10n.gameScore(score);
    // Current user uses brand blue fill → white ink; others sit on dark surface → blue accents.
    final nameColor = isCurrentUser ? colors.onPrimary : colors.onSurface;
    final scoreColor = isCurrentUser ? colors.onPrimary : colors.primary;
    final badgeColor = isCurrentUser
        ? colors.onPrimary.withValues(alpha: 0.85)
        : colors.primary;

    return Semantics(
      label: '$rank. $name, $scoreLabel',
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isCurrentUser ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '#$rank',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: nameColor,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isCurrentUser
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: nameColor,
                      ),
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 8),
                    Text(
                      l10n.leaderboardCurrentUser,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              scoreLabel,
              softWrap: false,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scoreColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
