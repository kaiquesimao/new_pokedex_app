import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/auth/presentation/providers/login_email_form_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_navigation_listener.dart';
import 'package:pokedex_app/features/legal/presentation/legal_acceptance.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:pokedex_app/shared/widgets/wide_viewport_backdrop.dart';

class LoginEmailPage extends ConsumerStatefulWidget {
  const LoginEmailPage({super.key});

  @override
  ConsumerState<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends ConsumerState<LoginEmailPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!await ensureLegalAccepted(context, ref)) return;

    await ref
        .read(loginEmailFormProvider.notifier)
        .submit(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(loginEmailFormProvider);
    listenPostLoginNavigation(ref);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: wideViewportAwareScaffoldColor(context),
      appBar: AppBar(title: Text(l10n.authLoginTitle)),
      body: Stack(
        children: [
          SafePageBody.belowAppBar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AuthHubNarrowFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.authLoginHeadline,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authLoginInstructions,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: l10n.authEmailLabel,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      label: l10n.authPasswordLabel,
                      controller: _passwordController,
                      errorText: form.error,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppSurfaceTextButton(
                        onPressed: () => context.push('/forgot-password'),
                        label: l10n.authForgotPasswordText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const LegalAcceptanceField(),
                    const SizedBox(height: 16),
                    AppButton(
                      label: l10n.authLoginButtonLabel,
                      isLoading: form.loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (form.loading)
            AuthLoadingOverlay(message: l10n.authLoadingSigningIn),
        ],
      ),
    );
  }
}
