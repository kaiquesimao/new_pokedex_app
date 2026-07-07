import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/domain/auth_account_policy.dart';
import 'package:pokedex_app/features/auth/domain/auth_email_verification_copy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/change_email_flow_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/otp_code_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  final _currentPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();
  var _otpCode = '';

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  Future<void> _submitCurrentPassword() async {
    await ref
        .read(changeEmailFlowProvider.notifier)
        .submitCurrentPassword(_currentPasswordController.text);
  }

  Future<void> _submitNewEmail() async {
    await ref
        .read(changeEmailFlowProvider.notifier)
        .submitNewEmail(_newEmailController.text);
  }

  Future<void> _submitVerification() async {
    await ref
        .read(changeEmailFlowProvider.notifier)
        .submitVerification(otpCode: _otpCode);
  }

  void _goBackStep() {
    ref.read(changeEmailFlowProvider.notifier).goBackStep();
  }

  void _finish() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).profileActionSuccess),
        backgroundColor: AppColorsLight.primary,
      ),
    );
    context.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (!auth.canEditCredentials) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              socialAccountCredentialsMessage(AppLocalizations.of(context)),
            ),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final flow = ref.watch(changeEmailFlowProvider);
    final step = flow.step;
    final usesFirebase = ref.watch(firebaseBootstrapProvider).isAvailable;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(step, l10n)),
        leading: step == ChangeEmailStep.success
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (step == ChangeEmailStep.currentPassword) {
                    context.pop();
                  } else {
                    _goBackStep();
                  }
                },
              ),
      ),
      body: SafePageBody.belowAppBar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (step != ChangeEmailStep.success) ...[
                _StepIndicator(current: _stepIndex(step), total: 3),
                const SizedBox(height: 32),
                Text(
                  _headline(step, l10n),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle(
                    step,
                    l10n: l10n,
                    usesFirebase: usesFirebase,
                    email: flow.pendingEmail,
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              switch (step) {
                ChangeEmailStep.currentPassword => AppPasswordField(
                  label: l10n.profileCurrentPasswordLabel,
                  controller: _currentPasswordController,
                  errorText: flow.error,
                ),
                ChangeEmailStep.newEmail => AppTextField(
                  label: l10n.changeEmailNewEmailLabel,
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: flow.error,
                ),
                ChangeEmailStep.verify =>
                  usesFirebase
                      ? _VerifyEmailBody(errorText: flow.error)
                      : OtpCodeField(
                          errorText: flow.error,
                          onChanged: (value) => _otpCode = value,
                          onCompleted: (value) {
                            _otpCode = value;
                            unawaited(_submitVerification());
                          },
                        ),
                ChangeEmailStep.success => _SuccessBody(
                  l10n: l10n,
                  email: flow.pendingEmail,
                  onDone: _finish,
                ),
              },
              if (step != ChangeEmailStep.success) ...[
                const SizedBox(height: 32),
                AppButton(
                  label: _primaryButtonLabel(
                    step,
                    l10n: l10n,
                    usesFirebase: usesFirebase,
                  ),
                  isLoading: flow.loading,
                  onPressed: flow.loading ? null : _onPrimaryPressed(step),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _stepIndex(ChangeEmailStep step) => switch (step) {
    ChangeEmailStep.currentPassword => 1,
    ChangeEmailStep.newEmail => 2,
    ChangeEmailStep.verify => 3,
    ChangeEmailStep.success => 3,
  };

  String _appBarTitle(ChangeEmailStep step, AppLocalizations l10n) =>
      switch (step) {
        ChangeEmailStep.success => l10n.changeEmailAppBarSuccess,
        ChangeEmailStep.verify => l10n.authVerifyEmailTitle,
        _ => l10n.changeEmailAppBarTitle,
      };

  String _headline(ChangeEmailStep step, AppLocalizations l10n) =>
      switch (step) {
        ChangeEmailStep.currentPassword =>
          l10n.changeEmailHeadlineCurrentPassword,
        ChangeEmailStep.newEmail => l10n.changeEmailHeadlineNewEmail,
        ChangeEmailStep.verify => l10n.changeEmailHeadlineVerify,
        ChangeEmailStep.success => '',
      };

  String _subtitle(
    ChangeEmailStep step, {
    required AppLocalizations l10n,
    required bool usesFirebase,
    required String email,
  }) =>
      switch (step) {
        ChangeEmailStep.currentPassword =>
          l10n.profileSecurityPasswordSubtitle,
        ChangeEmailStep.newEmail => AuthEmailVerificationCopy.withSpamReminder(
          l10n,
          usesFirebase
              ? l10n.changeEmailSubtitleNewEmailFirebase
              : l10n.changeEmailSubtitleNewEmailMock,
        ),
        ChangeEmailStep.verify => AuthEmailVerificationCopy.withSpamReminder(
          l10n,
          usesFirebase
              ? l10n.changeEmailSubtitleVerifyFirebase(email)
              : l10n.authForgotSubtitleOtp(email),
        ),
        ChangeEmailStep.success => '',
      };

  String _primaryButtonLabel(
    ChangeEmailStep step, {
    required AppLocalizations l10n,
    required bool usesFirebase,
  }) =>
      switch (step) {
        ChangeEmailStep.currentPassword => l10n.authContinueButton,
        ChangeEmailStep.newEmail => l10n.changeEmailSendVerificationButton,
        ChangeEmailStep.verify => usesFirebase
            ? l10n.authVerifyEmailAlreadyConfirmedButton
            : l10n.changeEmailConfirmCodeButton,
        ChangeEmailStep.success => l10n.profileFinishButton,
      };

  VoidCallback? _onPrimaryPressed(ChangeEmailStep step) => switch (step) {
    ChangeEmailStep.currentPassword => _submitCurrentPassword,
    ChangeEmailStep.newEmail => _submitNewEmail,
    ChangeEmailStep.verify => _submitVerification,
    ChangeEmailStep.success => null,
  };
}

class _VerifyEmailBody extends StatelessWidget {
  const _VerifyEmailBody({this.errorText});

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          Icons.mark_email_unread_outlined,
          size: 72,
          color: theme.colorScheme.primary,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 16),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final active = index < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.l10n,
    required this.email,
    required this.onDone,
  });

  final AppLocalizations l10n;
  final String email;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.changeEmailSuccessTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.changeEmailSuccessSubtitle(email),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        AppButton(label: l10n.profileBackToAccount, onPressed: onDone),
      ],
    );
  }
}
