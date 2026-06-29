import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/app.dart';
import 'package:pokedex_app/core/bootstrap/app_bootstrap.dart';
import 'package:pokedex_app/core/bootstrap/firebase_config_error_app.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final coldStart = await runColdStart();

  FlutterNativeSplash.remove();

  if (coldStart.firebaseConfigError) {
    runApp(const FirebaseConfigErrorApp());
    return;
  }

  runApp(
    UncontrolledProviderScope(
      container: coldStart.container,
      child: const PokedexApp(),
    ),
  );
}
