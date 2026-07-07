import 'package:flutter/material.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';

Future<bool?> showLogoutBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    builder: (context) => const _LogoutBottomSheet(),
  );
}

class _LogoutBottomSheet extends StatelessWidget {
  const _LogoutBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.profileLogoutConfirmSemantics,
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
              l10n.profileLogoutConfirmTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Semantics(
              label: l10n.profileLogoutConfirmYesSemantics,
              button: true,
              child: AppButton(
                label: l10n.profileLogoutConfirmYes,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: l10n.profileLogoutConfirmNoSemantics,
              button: true,
              child: AppButton(
                label: l10n.profileLogoutConfirmNo,
                variant: AppButtonVariant.outline,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
