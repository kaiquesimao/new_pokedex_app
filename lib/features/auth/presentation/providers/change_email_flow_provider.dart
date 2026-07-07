import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/auth_email_verification_copy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

enum ChangeEmailStep { currentPassword, newEmail, verify, success }

class ChangeEmailFlowState {
  const ChangeEmailFlowState({
    this.step = ChangeEmailStep.currentPassword,
    this.loading = false,
    this.error,
    this.verifiedCurrentPassword = '',
    this.pendingEmail = '',
  });

  final ChangeEmailStep step;
  final bool loading;
  final String? error;
  final String verifiedCurrentPassword;
  final String pendingEmail;

  ChangeEmailFlowState copyWith({
    ChangeEmailStep? step,
    bool? loading,
    String? error,
    String? verifiedCurrentPassword,
    String? pendingEmail,
    bool clearError = false,
  }) {
    return ChangeEmailFlowState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      verifiedCurrentPassword:
          verifiedCurrentPassword ?? this.verifiedCurrentPassword,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }
}

class ChangeEmailFlowNotifier extends Notifier<ChangeEmailFlowState> {
  @override
  ChangeEmailFlowState build() => const ChangeEmailFlowState();

  Future<void> submitCurrentPassword(String currentPassword) async {
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
        step: ChangeEmailStep.newEmail,
        verifiedCurrentPassword: currentPassword,
      );
    } on Object catch (e) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(loading: false, error: formatAuthException(l10n, e));
    }
  }

  Future<void> submitNewEmail(String newEmail) async {
    final trimmed = newEmail.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(error: l10n.authInvalidEmail);
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      await ref
          .read(authProvider.notifier)
          .requestEmailChange(
            currentPassword: state.verifiedCurrentPassword,
            newEmail: trimmed,
          );
      state = state.copyWith(
        loading: false,
        step: ChangeEmailStep.verify,
        pendingEmail: trimmed,
      );
    } on Object catch (e) {
      final l10n = lookupAppLocalizations(
        ref.read(appLocaleProvider).materialLocale,
      );
      state = state.copyWith(loading: false, error: formatAuthException(l10n, e));
    }
  }

  Future<void> submitVerification({String otpCode = ''}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final verified = await ref
          .read(authProvider.notifier)
          .completeEmailChangeVerification(
            expectedEmail: state.pendingEmail,
            otpCode: otpCode,
          );
      if (!verified) {
        state = state.copyWith(
          loading: false,
          error: ref.read(authProvider.notifier).usesFirebase
              ? AuthEmailVerificationCopy.unverifiedFirebase(
                  lookupAppLocalizations(
                    ref.read(appLocaleProvider).materialLocale,
                  ),
                )
              : lookupAppLocalizations(
                  ref.read(appLocaleProvider).materialLocale,
                ).authInvalidCodeTryAgain,
        );
        return;
      }
      state = state.copyWith(loading: false, step: ChangeEmailStep.success);
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
        ChangeEmailStep.newEmail => ChangeEmailStep.currentPassword,
        ChangeEmailStep.verify => ChangeEmailStep.newEmail,
        _ => state.step,
      },
    );
  }
}

final NotifierProvider<ChangeEmailFlowNotifier, ChangeEmailFlowState>
changeEmailFlowProvider =
    NotifierProvider.autoDispose<ChangeEmailFlowNotifier, ChangeEmailFlowState>(
      ChangeEmailFlowNotifier.new,
    );
