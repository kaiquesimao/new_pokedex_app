import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:pokedex_app/features/app_update/domain/app_update_service.dart';

/// Google Play In-App Updates via `package:in_app_update`.
///
/// Only works for release builds installed from Play (internal track+).
/// Local APK/sideload/debug installs typically return API-not-available.
class PlayAppUpdateService implements AppUpdateService {
  new({
    Future<AppUpdateInfo> Function()? checkForUpdateFn,
    Future<AppUpdateResult> Function()? startFlexibleUpdateFn,
    Future<void> Function()? completeFlexibleUpdateFn,
    Future<AppUpdateResult> Function()? performImmediateUpdateFn,
  }) : _checkForUpdate = checkForUpdateFn ?? InAppUpdate.checkForUpdate,
       _startFlexibleUpdate =
           startFlexibleUpdateFn ?? InAppUpdate.startFlexibleUpdate,
       _completeFlexibleUpdate =
           completeFlexibleUpdateFn ?? InAppUpdate.completeFlexibleUpdate,
       _performImmediateUpdate =
           performImmediateUpdateFn ?? InAppUpdate.performImmediateUpdate;

  final Future<AppUpdateInfo> Function() _checkForUpdate;
  final Future<AppUpdateResult> Function() _startFlexibleUpdate;
  final Future<void> Function() _completeFlexibleUpdate;
  final Future<AppUpdateResult> Function() _performImmediateUpdate;

  @override
  Future<AppUpdateAvailabilityInfo?> checkForUpdate() async {
    try {
      final info = await _checkForUpdate();
      final available =
          info.updateAvailability == UpdateAvailability.updateAvailable ||
          info.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress;
      return AppUpdateAvailabilityInfo(
        updateAvailable: available,
        flexibleAllowed: info.flexibleUpdateAllowed,
        immediateAllowed: info.immediateUpdateAllowed,
        alreadyDownloaded: info.installStatus == InstallStatus.downloaded,
        availableVersionCode: info.availableVersionCode,
      );
    } on PlatformException {
      // ERROR_API_NOT_AVAILABLE and friends — ignore quietly.
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<AppUpdateUserResult> startFlexibleUpdate() =>
      _mapResult(_startFlexibleUpdate);

  @override
  Future<void> completeFlexibleUpdate() => _completeFlexibleUpdate();

  @override
  Future<AppUpdateUserResult> performImmediateUpdate() =>
      _mapResult(_performImmediateUpdate);

  Future<AppUpdateUserResult> _mapResult(
    Future<AppUpdateResult> Function() run,
  ) async {
    try {
      final result = await run();
      return switch (result) {
        AppUpdateResult.success => AppUpdateUserResult.success,
        AppUpdateResult.userDeniedUpdate => AppUpdateUserResult.denied,
        AppUpdateResult.inAppUpdateFailed => AppUpdateUserResult.failed,
      };
    } on PlatformException {
      return AppUpdateUserResult.failed;
    } on MissingPluginException {
      return AppUpdateUserResult.unavailable;
    }
  }
}
