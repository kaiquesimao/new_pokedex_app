import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/auth/presentation/providers/login_email_form_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_navigation_listener.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/auth_loading_overlay.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

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
    await ref.read(loginEmailFormProvider.notifier).submit(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(loginEmailFormProvider);
    listenPostLoginNavigation(ref);
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Stack(
        children: [
          SafePageBody.belowAppBar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Entre com seu e-mail',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use o e-mail e a senha cadastrados no app. '
                    'Contas criadas com Google ou Apple devem entrar por esses botões.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'E-mail',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AppPasswordField(
                    label: 'Senha',
                    controller: _passwordController,
                    errorText: form.error,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Entrar',
                    isLoading: form.loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          if (form.loading) const AuthLoadingOverlay(message: 'Entrando...'),
        ],
      ),
    );
  }
}
