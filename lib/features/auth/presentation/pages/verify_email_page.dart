import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_email_verification_copy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/verify_email_ui_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/otp_code_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final flow = ref.read(registerFlowProvider);
      if (!flow.isComplete) {
        if (mounted) context.go('/register/email');
        return;
      }

      await ref.read(verifyEmailUiProvider.notifier).sendInitialOtpIfNeeded();
    });
  }

  Future<void> _completeRegistration({String otpCode = ''}) async {
    final success = await ref
        .read(verifyEmailUiProvider.notifier)
        .completeRegistration(otpCode: otpCode);
    if (success && mounted) context.go('/register/success');
  }

  Future<void> _resend() async {
    await ref.read(verifyEmailUiProvider.notifier).resend();
    if (!mounted) return;

    final ui = ref.read(verifyEmailUiProvider);
    if (ui.resent) {
      final usesFirebase = ref.read(firebaseBootstrapProvider).isAvailable;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usesFirebase
                ? AuthEmailVerificationCopy.withSpamReminder(
                    l10n,
                    l10n.authVerifyEmailResentEmail,
                  )
                : AuthEmailVerificationCopy.withSpamReminder(
                    l10n,
                    l10n.authVerifyEmailResentCode,
                  ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(registerFlowProvider);
    final ui = ref.watch(verifyEmailUiProvider);
    final theme = Theme.of(context);
    final usesFirebase = ref.watch(firebaseBootstrapProvider).isAvailable;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authVerifyEmailTitle)),
      body: Stack(
        children: [
          SafePageBody.belowAppBar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.authVerifyEmailHeadline,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    usesFirebase
                        ? AuthEmailVerificationCopy.withSpamReminder(
                            l10n,
                            l10n.authVerifyEmailLinkSent(flow.email),
                          )
                        : AuthEmailVerificationCopy.withSpamReminder(
                            l10n,
                            l10n.authVerifyEmailCodeSent(flow.email),
                          ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (usesFirebase) ...[
                    AppButton(
                      label: l10n.authVerifyEmailAlreadyConfirmedButton,
                      isLoading: ui.loading,
                      onPressed: _completeRegistration,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: AppSurfaceTextButton(
                        onPressed: _resend,
                        label: l10n.authVerifyEmailResendEmail,
                      ),
                    ),
                  ] else
                    OtpCodeField(
                      errorText: ui.error,
                      onCompleted: (code) =>
                          _completeRegistration(otpCode: code),
                      onResend: _resend,
                    ),
                  if (ui.error != null && usesFirebase) ...[
                    const SizedBox(height: 12),
                    Text(
                      ui.error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (ui.resent) ...[
                    const SizedBox(height: 8),
                    Text(
                      usesFirebase
                          ? AuthEmailVerificationCopy.withSpamReminder(
                              l10n,
                              l10n.authVerifyEmailResentEmail,
                            )
                          : AuthEmailVerificationCopy.withSpamReminder(
                              l10n,
                              l10n.authVerifyEmailResentCode,
                            ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (ui.loading && !usesFirebase)
            AuthLoadingOverlay(message: l10n.authVerifyEmailCreatingAccount),
          if (ui.loading && usesFirebase)
            AuthLoadingOverlay(message: l10n.authVerifyEmailVerifying),
        ],
      ),
    );
  }
}
