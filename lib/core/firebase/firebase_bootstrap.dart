import 'package:firebase_core/firebase_core.dart';
import 'package:pokedex_app/firebase_options.dart';

/// Firebase initialization (M2).
class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({required this.isAvailable});

  final bool isAvailable;
}

Future<FirebaseBootstrapResult> bootstrapFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return const FirebaseBootstrapResult(isAvailable: true);
  } catch (_) {
    return const FirebaseBootstrapResult(isAvailable: false);
  }
}
