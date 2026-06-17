import 'package:pokedex_app/core/firebase/firebase_bootstrap.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:riverpod/misc.dart';

const kFirebaseUnavailable = FirebaseBootstrapResult(isAvailable: false);

final Override firebaseUnavailableOverride = firebaseBootstrapProvider
    .overrideWithValue(
      kFirebaseUnavailable,
    );
