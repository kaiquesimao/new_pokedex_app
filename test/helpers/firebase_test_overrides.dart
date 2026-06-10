import 'package:pokedex_app/core/firebase/firebase_bootstrap.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';

const kFirebaseUnavailable = FirebaseBootstrapResult(isAvailable: false);

final firebaseUnavailableOverride =
    firebaseBootstrapProvider.overrideWithValue(kFirebaseUnavailable);
