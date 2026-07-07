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
      const SnackBar(
        content: Text('Ação realizada com sucesso'),
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
          const SnackBar(content: Text(socialAccountCredentialsMessage)),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(step)),
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
                  _headline(step),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle(
                    step,
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
                  label: 'Senha atual',
                  controller: _currentPasswordController,
                  errorText: flow.error,
                ),
                ChangeEmailStep.newEmail => AppTextField(
                  label: 'Novo e-mail',
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
                  email: flow.pendingEmail,
                  onDone: _finish,
                ),
              },
              if (step != ChangeEmailStep.success) ...[
                const SizedBox(height: 32),
                AppButton(
                  label: _primaryButtonLabel(step, usesFirebase: usesFirebase),
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

  String _appBarTitle(ChangeEmailStep step) => switch (step) {
    ChangeEmailStep.success => 'E-mail atualizado',
    ChangeEmailStep.verify => 'Confirmar e-mail',
    _ => 'Trocar e-mail',
  };

  String _headline(ChangeEmailStep step) => switch (step) {
    ChangeEmailStep.currentPassword => 'Qual é sua senha atual?',
    ChangeEmailStep.newEmail => 'Qual é o novo e-mail?',
    ChangeEmailStep.verify => 'Confirme o novo e-mail',
    ChangeEmailStep.success => '',
  };

  String _subtitle(
    ChangeEmailStep step, {
    required bool usesFirebase,
    required String email,
  }) => switch (step) {
    ChangeEmailStep.currentPassword =>
      'Por segurança, confirme sua senha antes de continuar.',
    ChangeEmailStep.newEmail => AuthEmailVerificationCopy.withSpamReminder(
      usesFirebase
          ? 'Enviaremos um link de verificação para o novo endereço.'
          : 'Informe o novo e-mail da sua conta.',
    ),
    ChangeEmailStep.verify => AuthEmailVerificationCopy.withSpamReminder(
      usesFirebase
          ? 'Abra o link enviado para $email e toque em "Já confirmei".'
          : 'Digite o código de 6 dígitos enviado para $email.',
    ),
    ChangeEmailStep.success => '',
  };

  String _primaryButtonLabel(
    ChangeEmailStep step, {
    required bool usesFirebase,
  }) => switch (step) {
    ChangeEmailStep.currentPassword => 'Continuar',
    ChangeEmailStep.newEmail => 'Enviar verificação',
    ChangeEmailStep.verify =>
      usesFirebase ? 'Já confirmei o e-mail' : 'Confirmar código',
    ChangeEmailStep.success => 'Concluir',
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
  const _SuccessBody({required this.email, required this.onDone});

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
          'E-mail atualizado!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sua conta agora usa $email.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        AppButton(label: 'Voltar à conta', onPressed: onDone),
      ],
    );
  }
}
