import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/env/env.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/features/app_update/data/noop_app_update_service.dart';
import 'package:pokedex_app/features/app_update/data/play_app_update_service.dart';
import 'package:pokedex_app/features/app_update/domain/app_update_service.dart';

/// Outcome of [AppUpdateController.checkOnLaunch] for the UI layer.
enum AppUpdateLaunchOutcome {
  /// Nothing to show (no update, wrong platform, or already dismissed).
  none,

  /// Flexible download finished (or was already downloaded); prompt restart.
  flexibleReadyToInstall,

  /// Immediate update was started (Play owns the UI).
  immediateStarted,
}

/// Coordinates Play in-app updates once per app session.
class AppUpdateController({
  required final AppUpdateService service,
  required final Future<int> Function() readInstalledVersionCode,
  required final int minimumRequiredVersionCode,
}) {
  var _checkStarted = false;
  var _dismissedThisSession = false;

  /// Runs the launch check. Safe to call multiple times; only the first
  /// attempt per session performs work (unless [force] is true — tests).
  Future<AppUpdateLaunchOutcome> checkOnLaunch({bool force = false}) async {
    if (!force && (_checkStarted || _dismissedThisSession)) {
      return AppUpdateLaunchOutcome.none;
    }
    _checkStarted = true;

    final info = await service.checkForUpdate();
    if (info == null || !info.updateAvailable) {
      return AppUpdateLaunchOutcome.none;
    }

    if (info.alreadyDownloaded) {
      return AppUpdateLaunchOutcome.flexibleReadyToInstall;
    }

    final installed = await readInstalledVersionCode();
    final forceImmediate =
        minimumRequiredVersionCode > 0 &&
        installed < minimumRequiredVersionCode &&
        info.immediateAllowed;

    if (forceImmediate) {
      final result = await service.performImmediateUpdate();
      if (result == AppUpdateUserResult.denied) {
        _dismissedThisSession = true;
      }
      return result == AppUpdateUserResult.success
          ? AppUpdateLaunchOutcome.immediateStarted
          : AppUpdateLaunchOutcome.none;
    }

    if (!info.flexibleAllowed) {
      return AppUpdateLaunchOutcome.none;
    }

    final result = await service.startFlexibleUpdate();
    if (result == AppUpdateUserResult.denied) {
      _dismissedThisSession = true;
      return AppUpdateLaunchOutcome.none;
    }
    if (result != AppUpdateUserResult.success) {
      return AppUpdateLaunchOutcome.none;
    }
    return AppUpdateLaunchOutcome.flexibleReadyToInstall;
  }

  /// Installs a downloaded flexible update (restarts the process).
  Future<void> completeFlexibleUpdate() => service.completeFlexibleUpdate();

  @visibleForTesting
  bool get dismissedThisSession => _dismissedThisSession;
}

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return const NoOpAppUpdateService();
  }
  return PlayAppUpdateService();
});

final appUpdateControllerProvider = Provider<AppUpdateController>((ref) {
  return AppUpdateController(
    service: ref.watch(appUpdateServiceProvider),
    minimumRequiredVersionCode: Env.androidMinRequiredVersionCode,
    readInstalledVersionCode: () async {
      final info = await ref.read(packageInfoProvider.future);
      return int.tryParse(info.buildNumber) ?? 0;
    },
  );
});
