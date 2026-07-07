import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

enum ChangePasswordStep { current, newPassword, confirm, success }

class ChangePasswordFlowState {
  const ChangePasswordFlowState({
    this.step = ChangePasswordStep.current,
    this.loading = false,
    this.error,
    this.verifiedCurrentPassword = '',
  });

  final ChangePasswordStep step;
  final bool loading;
  final String? error;
  final String verifiedCurrentPassword;

  ChangePasswordFlowState copyWith({
    ChangePasswordStep? step,
    bool? loading,
    String? error,
    String? verifiedCurrentPassword,
    bool clearError = false,
  }) {
    return ChangePasswordFlowState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      verifiedCurrentPassword:
          verifiedCurrentPassword ?? this.verifiedCurrentPassword,
    );
  }
}

class ChangePasswordFlowNotifier extends Notifier<ChangePasswordFlowState> {
  @override
  ChangePasswordFlowState build() => const ChangePasswordFlowState();

  Future<void> submitCurrent(String currentPassword) async {
    if (currentPassword.isEmpty) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(error: l10n.authEnterYourCurrentPassword);
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      final valid = await ref
          .read(authProvider.notifier)
          .verifyCurrentPassword(currentPassword);
      if (!valid) {
        final l10n = lookupAppLocalizations(
          ref.read(appLocaleProvider).materialLocale,
        );
        state = state.copyWith(
          loading: false,
          error: l10n.authCurrentPasswordIncorrect,
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        step: ChangePasswordStep.newPassword,
        verifiedCurrentPassword: currentPassword,
      );
    } finally {
      if (state.loading) {
        state = state.copyWith(loading: false);
      }
    }
  }

  void submitNew(String newPassword) {
    final passwordError = PasswordPolicy.validateWithL10n(
      lookupAppLocalizations(ref.read(appLocaleProvider).materialLocale),
      newPassword,
    );
    if (passwordError != null) {
      state = state.copyWith(error: passwordError);
      return;
    }
    state = state.copyWith(clearError: true, step: ChangePasswordStep.confirm);
  }

  Future<void> submitConfirm({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (confirmPassword != newPassword) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(error: l10n.authPasswordsDoNotMatch);
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(
            currentPassword: state.verifiedCurrentPassword,
            newPassword: newPassword,
          );
      state = state.copyWith(loading: false, step: ChangePasswordStep.success);
    } on Object catch (e) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(loading: false, error: formatAuthException(l10n, e));
    }
  }

  void goBackStep() {
    state = state.copyWith(
      clearError: true,
      step: switch (state.step) {
        ChangePasswordStep.newPassword => ChangePasswordStep.current,
        ChangePasswordStep.confirm => ChangePasswordStep.newPassword,
        _ => state.step,
      },
    );
  }
}

final NotifierProvider<ChangePasswordFlowNotifier, ChangePasswordFlowState>
changePasswordFlowProvider =
    NotifierProvider.autoDispose<
      ChangePasswordFlowNotifier,
      ChangePasswordFlowState
    >(
      ChangePasswordFlowNotifier.new,
    );
