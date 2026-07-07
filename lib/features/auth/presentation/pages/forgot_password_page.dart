import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/auth/domain/auth_email_verification_copy.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/forgot_password_flow_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/otp_code_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    await ref
        .read(forgotPasswordFlowProvider.notifier)
        .submitEmail(_emailController.text);
  }

  Future<void> _verifyOtp(String code) async {
    await ref.read(forgotPasswordFlowProvider.notifier).verifyOtp(code);
  }

  Future<void> _resendOtp() async {
    await ref.read(forgotPasswordFlowProvider.notifier).resendOtp();
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authForgotCodeResentSnackbar)),
      );
    }
  }

  Future<void> _submitNewPassword() async {
    await ref
        .read(forgotPasswordFlowProvider.notifier)
        .submitNewPassword(
          password: _passwordController.text,
          confirm: _confirmController.text,
        );
  }

  void _goBackStep() {
    ref.read(forgotPasswordFlowProvider.notifier).goBackStep();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(forgotPasswordFlowProvider);
    final step = flow.step;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(step, l10n)),
        leading:
            step == ForgotPasswordStep.success ||
                step == ForgotPasswordStep.emailSent
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (step == ForgotPasswordStep.email) {
                    context.pop();
                  } else {
                    _goBackStep();
                  }
                },
              ),
      ),
      body: Stack(
        children: [
          SafePageBody.belowAppBar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (step != ForgotPasswordStep.success &&
                      step != ForgotPasswordStep.emailSent) ...[
                    if (step != ForgotPasswordStep.otp)
                      _StepIndicator(current: _stepIndex(step), total: 3),
                    if (step != ForgotPasswordStep.otp)
                      const SizedBox(height: 32),
                    Text(
                      _headline(step, l10n),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle(step, flow.email, l10n),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  switch (step) {
                    ForgotPasswordStep.email => AppTextField(
                      label: l10n.authEmailLabel,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText: flow.error,
                    ),
                    ForgotPasswordStep.otp => OtpCodeField(
                      errorText: flow.error,
                      onCompleted: _verifyOtp,
                      onResend: _resendOtp,
                    ),
                    ForgotPasswordStep.newPassword => Column(
                      children: [
                        AppPasswordField(
                          label: l10n.authForgotNewPasswordLabel,
                          controller: _passwordController,
                          errorText: flow.error,
                        ),
                        const SizedBox(height: 16),
                        AppPasswordField(
                          label: l10n.authForgotConfirmNewPasswordLabel,
                          controller: _confirmController,
                        ),
                      ],
                    ),
                    ForgotPasswordStep.success => _SuccessBody(
                      onDone: () => context.go('/login/email'),
                    ),
                    ForgotPasswordStep.emailSent => _EmailSentBody(
                      email: flow.email,
                      onDone: () => context.go('/login/email'),
                    ),
                  },
                  if (step == ForgotPasswordStep.otp && flow.resent) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.authForgotCodeResentSnackbar,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (step == ForgotPasswordStep.email ||
                      step == ForgotPasswordStep.newPassword) ...[
                    const SizedBox(height: 32),
                    AppButton(
                      label: _primaryButtonLabel(step, l10n),
                      isLoading: flow.loading,
                      onPressed: flow.loading ? null : _onPrimaryPressed(step),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (flow.loading &&
              step != ForgotPasswordStep.success &&
              step != ForgotPasswordStep.emailSent)
            AuthLoadingOverlay(message: l10n.authProcessing),
        ],
      ),
    );
  }

  int _stepIndex(ForgotPasswordStep step) => switch (step) {
    ForgotPasswordStep.email => 1,
    ForgotPasswordStep.otp => 2,
    ForgotPasswordStep.newPassword => 3,
    ForgotPasswordStep.success => 3,
    ForgotPasswordStep.emailSent => 3,
  };

  String _appBarTitle(ForgotPasswordStep step, AppLocalizations l10n) =>
      switch (step) {
        ForgotPasswordStep.success => l10n.authForgotAppBarSuccess,
        ForgotPasswordStep.emailSent => l10n.authForgotAppBarEmailSent,
        _ => l10n.authForgotAppBarDefault,
      };

  String _headline(ForgotPasswordStep step, AppLocalizations l10n) =>
      switch (step) {
        ForgotPasswordStep.email => l10n.authForgotHeadlineEmail,
        ForgotPasswordStep.otp => l10n.authForgotHeadlineOtp,
        ForgotPasswordStep.newPassword => l10n.authForgotHeadlineNewPassword,
        ForgotPasswordStep.success => '',
        ForgotPasswordStep.emailSent => '',
      };

  String _subtitle(
    ForgotPasswordStep step,
    String email,
    AppLocalizations l10n,
  ) => switch (step) {
    ForgotPasswordStep.email => l10n.authForgotSubtitleEmail,
    ForgotPasswordStep.otp => AuthEmailVerificationCopy.withSpamReminder(
      l10n,
      l10n.authForgotSubtitleOtp(email),
    ),
    ForgotPasswordStep.newPassword => PasswordPolicy.requirementsHintOf(l10n),
    ForgotPasswordStep.success => '',
    ForgotPasswordStep.emailSent => '',
  };

  String _primaryButtonLabel(ForgotPasswordStep step, AppLocalizations l10n) =>
      switch (step) {
        ForgotPasswordStep.email => l10n.authForgotPrimaryButtonEmail,
        ForgotPasswordStep.newPassword =>
          l10n.authForgotPrimaryButtonNewPassword,
        _ => '',
      };

  VoidCallback? _onPrimaryPressed(ForgotPasswordStep step) => switch (step) {
    ForgotPasswordStep.email => _submitEmail,
    ForgotPasswordStep.newPassword => _submitNewPassword,
    _ => null,
  };
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
  const _SuccessBody({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
          l10n.authForgotSuccessTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authForgotSuccessSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        AppButton(label: l10n.authBackToLogin, onPressed: onDone),
      ],
    );
  }
}

class _EmailSentBody extends StatelessWidget {
  const _EmailSentBody({required this.email, required this.onDone});

  final String email;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.authForgotVerifyEmailTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AuthEmailVerificationCopy.withSpamReminder(
            l10n,
            l10n.authForgotVerifyEmailSent(email),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        AppButton(label: l10n.authBackToLogin, onPressed: onDone),
      ],
    );
  }
}
