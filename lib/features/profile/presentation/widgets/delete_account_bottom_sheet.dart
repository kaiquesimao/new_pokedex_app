import 'package:flutter/material.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';

/// Data confirmed by the account deletion sheet.
class DeleteAccountSheetResult {
  /// Creates a deletion confirmation result.
  const DeleteAccountSheetResult({this.password});

  /// Current password when password reauthentication is required.
  final String? password;
}

/// Shows the account deletion confirmation sheet.
Future<DeleteAccountSheetResult?> showDeleteAccountBottomSheet(
  BuildContext context, {
  required bool requirePassword,
}) {
  return showModalBottomSheet<DeleteAccountSheetResult>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (context) =>
        _DeleteAccountBottomSheet(requirePassword: requirePassword),
  );
}

class _DeleteAccountBottomSheet extends StatefulWidget {
  const _DeleteAccountBottomSheet({required this.requirePassword});

  final bool requirePassword;

  @override
  State<_DeleteAccountBottomSheet> createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState extends State<_DeleteAccountBottomSheet> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.of(context).pop(
      DeleteAccountSheetResult(
        password: widget.requirePassword ? _passwordController.text : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.profileDeleteAccountConfirmSemantics,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          32 + MediaQuery.viewInsetsOf(context).bottom,
        ),
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
              l10n.profileDeleteAccountConfirmTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.profileDeleteAccountConfirmBody,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (widget.requirePassword) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _confirm(),
                decoration: InputDecoration(
                  hintText: l10n.profileDeleteAccountPasswordHint,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Semantics(
              label: l10n.profileDeleteAccountConfirmYesSemantics,
              button: true,
              child: AppButton(
                label: l10n.profileDeleteAccountConfirmYes,
                onPressed: _confirm,
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: l10n.profileDeleteAccountConfirmNoSemantics,
              button: true,
              child: AppButton(
                label: l10n.profileDeleteAccountConfirmNo,
                variant: AppButtonVariant.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
