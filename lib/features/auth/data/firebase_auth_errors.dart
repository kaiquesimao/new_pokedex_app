import 'package:firebase_auth/firebase_auth.dart';

String firebaseAuthErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'E-mail inválido',
      'user-disabled' => 'Conta desativada',
      'user-not-found' => 'Usuário não encontrado',
      'wrong-password' => 'Senha incorreta',
      'email-already-in-use' => 'Este e-mail já está em uso',
      'weak-password' => 'A senha deve ter pelo menos 6 caracteres',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde',
      'network-request-failed' => 'Sem conexão. Verifique sua internet',
      'requires-recent-login' => 'Faça login novamente para continuar',
      'invalid-credential' =>
        'Credencial inválida. Verifique SHA-1/SHA-256 no Firebase e baixe o google-services.json novamente',
      'account-exists-with-different-credential' =>
        'Este e-mail já está cadastrado com outro método de login',
      'operation-not-allowed' =>
        'Este método de login não está habilitado no Firebase',
      _ => error.message ?? 'Erro de autenticação',
    };
  }
  return error.toString();
}
