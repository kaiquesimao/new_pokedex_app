import 'package:pokedex_app/features/app_update/domain/app_update_service.dart';

/// No-op used on web, iOS, and any non-Play Android install path tests.
class const NoOpAppUpdateService() implements AppUpdateService {
  @override
  Future<AppUpdateAvailabilityInfo?> checkForUpdate() async => null;

  @override
  Future<AppUpdateUserResult> startFlexibleUpdate() async =>
      AppUpdateUserResult.unavailable;

  @override
  Future<void> completeFlexibleUpdate() async {}

  @override
  Future<AppUpdateUserResult> performImmediateUpdate() async =>
      AppUpdateUserResult.unavailable;
}
