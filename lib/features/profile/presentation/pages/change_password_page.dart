import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/domain/auth_account_policy.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/change_password_flow_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_password_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitCurrent() async {
    await ref
        .read(changePasswordFlowProvider.notifier)
        .submitCurrent(_currentController.text);
  }

  void _submitNew() {
    ref
        .read(changePasswordFlowProvider.notifier)
        .submitNew(_newController.text);
  }

  Future<void> _submitConfirm() async {
    await ref
        .read(changePasswordFlowProvider.notifier)
        .submitConfirm(
          newPassword: _newController.text,
          confirmPassword: _confirmController.text,
        );
  }

  void _goBackStep() {
    ref.read(changePasswordFlowProvider.notifier).goBackStep();
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

    final flow = ref.watch(changePasswordFlowProvider);
    final step = flow.step;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(step, l10n)),
        leading: step == ChangePasswordStep.success
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (step == ChangePasswordStep.current) {
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
              if (step != ChangePasswordStep.success) ...[
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
                  _subtitle(step, l10n),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              switch (step) {
                ChangePasswordStep.current => AppPasswordField(
                  label: l10n.profileCurrentPasswordLabel,
                  controller: _currentController,
                  errorText: flow.error,
                ),
                ChangePasswordStep.newPassword => AppPasswordField(
                  label: l10n.authForgotNewPasswordLabel,
                  controller: _newController,
                  errorText: flow.error,
                ),
                ChangePasswordStep.confirm => AppPasswordField(
                  label: l10n.authForgotConfirmNewPasswordLabel,
                  controller: _confirmController,
                  errorText: flow.error,
                ),
                ChangePasswordStep.success => _SuccessBody(
                  l10n: l10n,
                  onDone: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context).profileActionSuccess,
                        ),
                        backgroundColor: AppColorsLight.primary,
                      ),
                    );
                    context.pop();
                  },
                ),
              },
              if (step != ChangePasswordStep.success) ...[
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
    );
  }

  int _stepIndex(ChangePasswordStep step) => switch (step) {
    ChangePasswordStep.current => 1,
    ChangePasswordStep.newPassword => 2,
    ChangePasswordStep.confirm => 3,
    ChangePasswordStep.success => 3,
  };

  String _appBarTitle(ChangePasswordStep step, AppLocalizations l10n) =>
      switch (step) {
        ChangePasswordStep.success => l10n.changePasswordAppBarSuccess,
        _ => l10n.changePasswordAppBarTitle,
      };

  String _headline(ChangePasswordStep step, AppLocalizations l10n) =>
      switch (step) {
        ChangePasswordStep.current => l10n.changePasswordHeadlineCurrent,
        ChangePasswordStep.newPassword => l10n.authForgotHeadlineNewPassword,
        ChangePasswordStep.confirm => l10n.changePasswordHeadlineConfirm,
        ChangePasswordStep.success => '',
      };

  String _subtitle(ChangePasswordStep step, AppLocalizations l10n) =>
      switch (step) {
        ChangePasswordStep.current => l10n.profileSecurityPasswordSubtitle,
        ChangePasswordStep.newPassword => PasswordPolicy.requirementsHintOf(
          l10n,
        ),
        ChangePasswordStep.confirm => l10n.changePasswordSubtitleConfirm,
        ChangePasswordStep.success => '',
      };

  String _primaryButtonLabel(
    ChangePasswordStep step,
    AppLocalizations l10n,
  ) =>
      switch (step) {
        ChangePasswordStep.current => l10n.authContinueButton,
        ChangePasswordStep.newPassword => l10n.authContinueButton,
        ChangePasswordStep.confirm => l10n.changePasswordSaveButton,
        ChangePasswordStep.success => l10n.profileFinishButton,
      };

  VoidCallback? _onPrimaryPressed(ChangePasswordStep step) => switch (step) {
    ChangePasswordStep.current => _submitCurrent,
    ChangePasswordStep.newPassword => _submitNew,
    ChangePasswordStep.confirm => _submitConfirm,
    ChangePasswordStep.success => null,
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
  const _SuccessBody({required this.l10n, required this.onDone});

  final AppLocalizations l10n;
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
          l10n.changePasswordSuccessTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.changePasswordSuccessSubtitle,
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
