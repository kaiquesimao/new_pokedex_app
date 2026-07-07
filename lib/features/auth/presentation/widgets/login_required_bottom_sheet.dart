import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';

Future<void> showLoginRequiredBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (context) => const _LoginRequiredBottomSheet(),
  );
}

class _LoginRequiredBottomSheet extends StatelessWidget {
  const _LoginRequiredBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.authLoginRequiredSemanticsLabel,
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
              l10n.authLoginRequiredTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.authLoginRequiredDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Semantics(
              label: l10n.authLoginRequiredSignIn,
              button: true,
              child: AppButton(
                label: l10n.authLoginRequiredSignIn,
                onPressed: () {
                  Navigator.of(context).pop();
                  unawaited(context.push('/login'));
                },
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: l10n.authLoginRequiredCreateAccount,
              button: true,
              child: AppButton(
                label: l10n.authLoginRequiredCreateAccount,
                variant: AppButtonVariant.outline,
                onPressed: () {
                  Navigator.of(context).pop();
                  unawaited(context.push('/register'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
