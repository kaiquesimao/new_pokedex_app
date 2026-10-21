import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/app_update/domain/app_update_service.dart';
import 'package:pokedex_app/features/app_update/presentation/providers/app_update_provider.dart';

class _FakeAppUpdateService implements AppUpdateService {
  AppUpdateAvailabilityInfo? info;
  AppUpdateUserResult flexibleResult = AppUpdateUserResult.success;
  AppUpdateUserResult immediateResult = AppUpdateUserResult.success;
  int checkCalls = 0;
  int flexibleCalls = 0;
  int immediateCalls = 0;
  int completeCalls = 0;

  @override
  Future<AppUpdateAvailabilityInfo?> checkForUpdate() async {
    checkCalls++;
    return info;
  }

  @override
  Future<AppUpdateUserResult> startFlexibleUpdate() async {
    flexibleCalls++;
    return flexibleResult;
  }

  @override
  Future<void> completeFlexibleUpdate() async {
    completeCalls++;
  }

  @override
  Future<AppUpdateUserResult> performImmediateUpdate() async {
    immediateCalls++;
    return immediateResult;
  }
}

void main() {
  group('AppUpdateController', () {
    test('returns none when Play API has no update', () async {
      final service = _FakeAppUpdateService()
        ..info = null;
      final controller = AppUpdateController(
        service: service,
        minimumRequiredVersionCode: 0,
        readInstalledVersionCode: () async => 26,
      );

      final outcome = await controller.checkOnLaunch();

      expect(outcome, AppUpdateLaunchOutcome.none);
      expect(service.flexibleCalls, 0);
    });

    test('starts flexible update by default and reports ready', () async {
      final service = _FakeAppUpdateService()
        ..info = const AppUpdateAvailabilityInfo(
          updateAvailable: true,
          flexibleAllowed: true,
          immediateAllowed: true,
          alreadyDownloaded: false,
          availableVersionCode: 27,
        );
      final controller = AppUpdateController(
        service: service,
        minimumRequiredVersionCode: 0,
        readInstalledVersionCode: () async => 26,
      );

      final outcome = await controller.checkOnLaunch();

      expect(outcome, AppUpdateLaunchOutcome.flexibleReadyToInstall);
      expect(service.flexibleCalls, 1);
      expect(service.immediateCalls, 0);
    });

    test('skips Play prompt when update already downloaded', () async {
      final service = _FakeAppUpdateService()
        ..info = const AppUpdateAvailabilityInfo(
          updateAvailable: true,
          flexibleAllowed: true,
          immediateAllowed: true,
          alreadyDownloaded: true,
          availableVersionCode: 27,
        );
      final controller = AppUpdateController(
        service: service,
        minimumRequiredVersionCode: 0,
        readInstalledVersionCode: () async => 26,
      );

      final outcome = await controller.checkOnLaunch();

      expect(outcome, AppUpdateLaunchOutcome.flexibleReadyToInstall);
      expect(service.flexibleCalls, 0);
    });

    test('does not repeat after user denies in the same session', () async {
      final service = _FakeAppUpdateService()
        ..info = const AppUpdateAvailabilityInfo(
          updateAvailable: true,
          flexibleAllowed: true,
          immediateAllowed: false,
          alreadyDownloaded: false,
        )
        ..flexibleResult = AppUpdateUserResult.denied;
      final controller = AppUpdateController(
        service: service,
        minimumRequiredVersionCode: 0,
        readInstalledVersionCode: () async => 26,
      );

      expect(await controller.checkOnLaunch(), AppUpdateLaunchOutcome.none);
      expect(controller.dismissedThisSession, isTrue);

      expect(await controller.checkOnLaunch(), AppUpdateLaunchOutcome.none);
      expect(service.checkCalls, 1);
      expect(service.flexibleCalls, 1);
    });

    test('uses immediate update when below minimum required version', () async {
      final service = _FakeAppUpdateService()
        ..info = const AppUpdateAvailabilityInfo(
          updateAvailable: true,
          flexibleAllowed: true,
          immediateAllowed: true,
          alreadyDownloaded: false,
          availableVersionCode: 30,
        );
      final controller = AppUpdateController(
        service: service,
        minimumRequiredVersionCode: 28,
        readInstalledVersionCode: () async => 26,
      );

      final outcome = await controller.checkOnLaunch();

      expect(outcome, AppUpdateLaunchOutcome.immediateStarted);
      expect(service.immediateCalls, 1);
      expect(service.flexibleCalls, 0);
    });

    test('completeFlexibleUpdate delegates to the service', () async {
      final service = _FakeAppUpdateService();
      final controller = AppUpdateController(
        service: service,
        minimumRequiredVersionCode: 0,
        readInstalledVersionCode: () async => 1,
      );

      await controller.completeFlexibleUpdate();

      expect(service.completeCalls, 1);
    });
  });
}
