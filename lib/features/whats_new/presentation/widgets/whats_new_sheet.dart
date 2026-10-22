import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';

enum WhatsNewSheetAction { dismiss, rate, play }

Future<WhatsNewSheetAction?> showWhatsNewSheet(
  BuildContext context, {
  required String versionName,
  required String changelog,
}) {
  return showModalBottomSheet<WhatsNewSheetAction>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) =>
        WhatsNewSheet(versionName: versionName, changelog: changelog),
  );
}

class const WhatsNewSheet({
  required final String versionName,
  required final String changelog,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final maxBodyHeight = MediaQuery.sizeOf(context).height * 0.4;

    return Semantics(
      label: l10n.whatsNewSheetSemantics,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.whatsNewTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.whatsNewVersionLabel(versionName),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxBodyHeight),
              child: SingleChildScrollView(
                child: Text(changelog, style: theme.textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              label: l10n.whatsNewDismissSemantics,
              button: true,
              child: AppButton(
                label: l10n.whatsNewDismissButton,
                onPressed: () =>
                    Navigator.of(context).pop(WhatsNewSheetAction.dismiss),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: l10n.whatsNewPlaySemantics,
                    button: true,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(WhatsNewSheetAction.play),
                      child: Text(l10n.whatsNewPlayButton),
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: l10n.whatsNewRateSemantics,
                    button: true,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(WhatsNewSheetAction.rate),
                      child: Text(l10n.whatsNewRateButton),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
