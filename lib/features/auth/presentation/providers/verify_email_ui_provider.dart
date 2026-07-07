import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/auth_email_verification_copy.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/register_flow_provider.dart';

class VerifyEmailUiState {
  const VerifyEmailUiState({
    this.loading = false,
    this.error,
    this.resent = false,
  });

  final bool loading;
  final String? error;
  final bool resent;

  VerifyEmailUiState copyWith({
    bool? loading,
    String? error,
    bool? resent,
    bool clearError = false,
  }) {
    return VerifyEmailUiState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      resent: resent ?? this.resent,
    );
  }
}

class VerifyEmailUiNotifier extends Notifier<VerifyEmailUiState> {
  @override
  VerifyEmailUiState build() => const VerifyEmailUiState();

  bool get _usesFirebase => ref.read(authProvider.notifier).usesFirebase;

  Future<void> sendInitialOtpIfNeeded() async {
    final flow = ref.read(registerFlowProvider);
    if (!flow.isComplete) return;

    if (!_usesFirebase) {
      try {
        await ref.read(authProvider.notifier).sendOtp(email: flow.email);
      } on Object catch (e) {
        state = state.copyWith(error: formatAuthException(e));
      }
    }
  }

  Future<bool> completeRegistration({String otpCode = ''}) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final flow = ref.read(registerFlowProvider);
      final verified = await ref
          .read(authProvider.notifier)
          .verifyOtp(email: flow.email, code: otpCode);

      if (!verified) {
        if (ref.mounted) {
          state = state.copyWith(
            loading: false,
            error: _usesFirebase
                ? AuthEmailVerificationCopy.unverifiedFirebase
                : 'Código inválido. Tente novamente.',
          );
        }
        return false;
      }

      final auth = ref.read(authProvider.notifier);
      await auth.signUp(
        email: flow.email,
        password: flow.password,
        name: flow.name,
      );
      auth.acknowledgeEmailVerification();

      if (!ref.mounted) return false;

      state = state.copyWith(loading: false);
      return true;
    } on Object catch (e) {
      if (ref.mounted) {
        state = state.copyWith(loading: false, error: formatAuthException(e));
      }
      return false;
    }
  }

  Future<void> resend() async {
    final flow = ref.read(registerFlowProvider);
    try {
      await ref.read(authProvider.notifier).sendOtp(email: flow.email);
      state = state.copyWith(resent: true, clearError: true);
    } on Object catch (e) {
      state = state.copyWith(error: formatAuthException(e));
    }
  }
}

final NotifierProvider<VerifyEmailUiNotifier, VerifyEmailUiState>
verifyEmailUiProvider =
    NotifierProvider.autoDispose<VerifyEmailUiNotifier, VerifyEmailUiState>(
      VerifyEmailUiNotifier.new,
    );
