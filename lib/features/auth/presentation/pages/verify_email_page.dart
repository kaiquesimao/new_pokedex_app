import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_email_verification_copy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/verify_email_ui_provider.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthEmailVerificationCopy.withSpamReminder(
              usesFirebase
                  ? 'E-mail de verificação reenviado.'
                  : 'Código reenviado.',
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

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar e-mail')),
      body: Stack(
        children: [
          SafePageBody.belowAppBar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Confirme seu e-mail',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AuthEmailVerificationCopy.withSpamReminder(
                      usesFirebase
                          ? 'Enviamos um link de verificação para ${flow.email}. Abra o e-mail, confirme o link e volte aqui para continuar.'
                          : 'Enviamos um código de 6 dígitos para ${flow.email}.',
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (usesFirebase) ...[
                    AppButton(
                      label: 'Já confirmei no e-mail',
                      isLoading: ui.loading,
                      onPressed: _completeRegistration,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _resend,
                        child: const Text('Reenviar e-mail'),
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
                      AuthEmailVerificationCopy.withSpamReminder(
                        usesFirebase
                            ? 'Um novo e-mail foi enviado.'
                            : 'Um novo código foi enviado.',
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
            const AuthLoadingOverlay(message: 'Criando conta...'),
          if (ui.loading && usesFirebase)
            const AuthLoadingOverlay(message: 'Verificando...'),
        ],
      ),
    );
  }
}
