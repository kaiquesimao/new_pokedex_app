import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/providers/home_tutorial_provider.dart';
import 'package:pokedex_app/features/reviews/presentation/providers/app_review_provider.dart';
import 'package:pokedex_app/features/whats_new/domain/whats_new_decision.dart';
import 'package:pokedex_app/features/whats_new/presentation/providers/whats_new_provider.dart';
import 'package:pokedex_app/features/whats_new/presentation/widgets/whats_new_sheet.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Shows release notes once per versionCode after the home tutorial, if any.
class const WhatsNewHost({required final Widget child, super.key})
    extends ConsumerStatefulWidget {
  @override
  ConsumerState<WhatsNewHost> createState() => _WhatsNewHostState();
}

class _WhatsNewHostState extends ConsumerState<WhatsNewHost> {
  var _finished = false;
  var _waitingForTutorial = false;
  var _suppressBecauseFirstRun = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _schedule());
  }

  void _schedule() {
    if (!mounted) return;
    final tutorial = ref.read(homeTutorialProvider);
    final lastSeen = readWhatsNewLastSeenVersionCode(
      ref.read(sharedPreferencesProvider),
    );
    _suppressBecauseFirstRun = lastSeen == null && !tutorial.completed;

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || _finished) return;
      _evaluate();
    });
  }

  void _evaluate() {
    if (_finished || !mounted) return;
    if (ref.read(homeTutorialProvider).isActive) {
      _waitingForTutorial = true;
      return;
    }
    unawaited(_resolve(forceFirstRun: _suppressBecauseFirstRun));
  }

  Future<void> _resolve({required bool forceFirstRun}) async {
    if (_finished || !mounted) return;
    _finished = true;

    final info = await ref.read(packageInfoProvider.future);
    if (!mounted) return;
    final versionCode = int.tryParse(info.buildNumber);
    if (versionCode == null) return;

    final prompt = await ref
        .read(whatsNewCoordinatorProvider)
        .resolve(
          currentVersionCode: versionCode,
          versionName: info.version,
          locale: ref.read(appLocaleProvider),
          homeTutorialCompleted:
              !forceFirstRun && ref.read(homeTutorialProvider).completed,
        );
    if (!mounted || prompt == null) return;

    final action = await showWhatsNewSheet(
      context,
      versionName: prompt.versionName,
      changelog: prompt.body,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case WhatsNewSheetAction.dismiss:
        return;
      case WhatsNewSheetAction.play:
        context.go('/game');
      case WhatsNewSheetAction.rate:
        try {
          await ref.read(appReviewControllerProvider).rateFromSettings();
        } on Object {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).profileRateAppError),
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeTutorialProvider, (previous, next) {
      if (!_waitingForTutorial || _finished || next.isActive) return;
      _waitingForTutorial = false;
      unawaited(_resolve(forceFirstRun: _suppressBecauseFirstRun));
    });
    return widget.child;
  }
}
