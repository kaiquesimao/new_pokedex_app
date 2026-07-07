import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/auth_email_verification_copy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';

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
      state = state.copyWith(error: 'Informe sua senha atual');
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      final valid = await ref
          .read(authProvider.notifier)
          .verifyCurrentPassword(currentPassword);
      if (!valid) {
        state = state.copyWith(loading: false, error: 'Senha atual incorreta');
        return;
      }
      state = state.copyWith(
        loading: false,
        step: ChangeEmailStep.newEmail,
        verifiedCurrentPassword: currentPassword,
      );
    } on Object catch (e) {
      state = state.copyWith(loading: false, error: formatAuthException(e));
    }
  }

  Future<void> submitNewEmail(String newEmail) async {
    final trimmed = newEmail.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      state = state.copyWith(error: 'Informe um e-mail válido');
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
      state = state.copyWith(loading: false, error: formatAuthException(e));
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
              ? AuthEmailVerificationCopy.unverifiedFirebase
              : 'Código inválido. Tente novamente.',
        );
        return;
      }
      state = state.copyWith(loading: false, step: ChangeEmailStep.success);
    } on Object catch (e) {
      state = state.copyWith(loading: false, error: formatAuthException(e));
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
