import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/auth_account_policy.dart';
import 'package:pokedex_app/features/auth/domain/display_name_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class EditNamePage extends ConsumerStatefulWidget {
  const EditNamePage({super.key});

  @override
  ConsumerState<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends ConsumerState<EditNamePage> {
  final _controller = TextEditingController();
  var _didSetInitial = false;
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validationError = DisplayNamePolicy.validate(_controller.text);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).updateDisplayName(_controller.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ação realizada com sucesso'),
          backgroundColor: AppColorsLight.primary,
        ),
      );
      context.go('/profile');
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _error = formatAuthException(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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

    if (!_didSetInitial) {
      _controller.text = auth.displayName ?? '';
      _didSetInitial = true;
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar nome')),
      body: SafePageBody.belowAppBar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Como devemos te chamar?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Este nome aparece no perfil e ao entrar na conta.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Nome',
                controller: _controller,
                errorText: _error,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Salvar',
                isLoading: _loading,
                onPressed: _loading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
