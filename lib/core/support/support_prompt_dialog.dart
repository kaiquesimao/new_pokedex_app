import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/support/app_support_links.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Centered Material support dialog (dimmed barrier, dismissible).
///
/// Primary opens Ko-fi; secondary / barrier dismiss without navigating.
Future<void> showSupportPromptDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.supportPromptTitle),
        content: Text(l10n.supportPromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.supportPromptNotNow),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final opened = await AppSupportLinks.openDonationPage();
              if (opened || !context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.profileSupportError)),
              );
            },
            child: Text(l10n.aboutSupportButton),
          ),
        ],
      );
    },
  );
}
