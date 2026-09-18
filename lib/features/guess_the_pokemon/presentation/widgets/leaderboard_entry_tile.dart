import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class const LeaderboardEntryTile({
  required this.rank,
  required this.playerName,
  required this.score,
  required this.isCurrentUser,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final name = playerName.trim().isEmpty
        ? l10n.leaderboardAnonymousTrainer
        : playerName;
    final scoreLabel = l10n.gameScore(score);

    return Semantics(
      label: '$rank. $name, $scoreLabel',
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentUser
              ? Border.all(color: theme.colorScheme.primary)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '#$rank',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isCurrentUser
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  if (isCurrentUser)
                    Text(
                      l10n.leaderboardCurrentUser,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              scoreLabel,
              softWrap: false,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final int rank;
  final String playerName;
  final int score;
  final bool isCurrentUser;
}
