import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:pokedex_app/features/app_update/data/play_app_update_service.dart';
import 'package:pokedex_app/features/app_update/domain/app_update_service.dart';

AppUpdateInfo _info({
  UpdateAvailability availability = UpdateAvailability.updateAvailable,
  bool flexible = true,
  bool immediate = true,
  InstallStatus status = InstallStatus.unknown,
  int? versionCode = 27,
}) {
  return AppUpdateInfo(
    updateAvailability: availability,
    immediateUpdateAllowed: immediate,
    immediateAllowedPreconditions: null,
    flexibleUpdateAllowed: flexible,
    flexibleAllowedPreconditions: null,
    availableVersionCode: versionCode,
    installStatus: status,
    packageName: 'com.example.pokedex',
    clientVersionStalenessDays: 1,
    updatePriority: 0,
  );
}

void main() {
  group('PlayAppUpdateService', () {
    test('maps updateAvailable + flags from Play info', () async {
      final service = PlayAppUpdateService(
        checkForUpdateFn: () async => _info(
          immediate: false,
          status: InstallStatus.downloaded,
          versionCode: 30,
        ),
      );

      final info = await service.checkForUpdate();

      expect(info, isNotNull);
      expect(info!.updateAvailable, isTrue);
      expect(info.flexibleAllowed, isTrue);
      expect(info.immediateAllowed, isFalse);
      expect(info.alreadyDownloaded, isTrue);
      expect(info.availableVersionCode, 30);
    });

    test('treats developerTriggeredUpdateInProgress as available', () async {
      final service = PlayAppUpdateService(
        checkForUpdateFn: () async => _info(
          availability: UpdateAvailability.developerTriggeredUpdateInProgress,
          status: InstallStatus.downloading,
        ),
      );

      final info = await service.checkForUpdate();

      expect(info!.updateAvailable, isTrue);
      expect(info.alreadyDownloaded, isFalse);
    });

    test('returns null when Play API is unavailable', () async {
      final service = PlayAppUpdateService(
        checkForUpdateFn: () async {
          throw PlatformException(code: 'TASK_FAILURE');
        },
      );

      expect(await service.checkForUpdate(), isNull);
    });

    test('returns null on MissingPluginException', () async {
      final service = PlayAppUpdateService(
        checkForUpdateFn: () async {
          throw MissingPluginException('in_app_update');
        },
      );

      expect(await service.checkForUpdate(), isNull);
    });

    test('maps AppUpdateResult values for flexible flow', () async {
      final success = PlayAppUpdateService(
        startFlexibleUpdateFn: () async => AppUpdateResult.success,
      );
      final denied = PlayAppUpdateService(
        startFlexibleUpdateFn: () async => AppUpdateResult.userDeniedUpdate,
      );
      final failed = PlayAppUpdateService(
        startFlexibleUpdateFn: () async => AppUpdateResult.inAppUpdateFailed,
      );

      expect(await success.startFlexibleUpdate(), AppUpdateUserResult.success);
      expect(await denied.startFlexibleUpdate(), AppUpdateUserResult.denied);
      expect(await failed.startFlexibleUpdate(), AppUpdateUserResult.failed);
    });

    test('maps PlatformException on update start to failed', () async {
      final service = PlayAppUpdateService(
        performImmediateUpdateFn: () async {
          throw PlatformException(code: 'IN_APP_UPDATE_FAILED');
        },
      );

      expect(
        await service.performImmediateUpdate(),
        AppUpdateUserResult.failed,
      );
    });

    test('completeFlexibleUpdate delegates to injected callback', () async {
      var completed = false;
      final service = PlayAppUpdateService(
        completeFlexibleUpdateFn: () async {
          completed = true;
        },
      );

      await service.completeFlexibleUpdate();

      expect(completed, isTrue);
    });
  });
}
