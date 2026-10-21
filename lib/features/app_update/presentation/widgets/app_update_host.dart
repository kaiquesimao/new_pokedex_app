import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/app_update/presentation/providers/app_update_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Runs the Play in-app update check once the widget tree (and l10n) is ready.
///
/// Renders nothing; shows a SnackBar when a flexible update is ready to apply.
class const AppUpdateHost({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<AppUpdateHost> createState() => _AppUpdateHostState();
}

class _AppUpdateHostState extends ConsumerState<AppUpdateHost> {
  var _didSchedule = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleCheck());
  }

  void _scheduleCheck() {
    if (_didSchedule || !mounted) return;
    _didSchedule = true;
    unawaited(_runCheck());
  }

  Future<void> _runCheck() async {
    final outcome = await ref
        .read(appUpdateControllerProvider)
        .checkOnLaunch();
    if (!mounted) return;
    if (outcome == AppUpdateLaunchOutcome.flexibleReadyToInstall) {
      _showRestartSnackBar();
    }
  }

  void _showRestartSnackBar() {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.appUpdateReadyMessage),
          duration: const Duration(seconds: 12),
          action: SnackBarAction(
            label: l10n.appUpdateRestartAction,
            onPressed: () {
              unawaited(
                ref
                    .read(appUpdateControllerProvider)
                    .completeFlexibleUpdate(),
              );
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
