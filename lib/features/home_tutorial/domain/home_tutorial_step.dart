import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Coach-mark steps on the home shell / Pokédex list.
enum HomeTutorialStepId {
  search,
  filters,
  listCard,
  bottomNav,
}

extension HomeTutorialStepIdL10n on HomeTutorialStepId {
  String title(AppLocalizations l10n) => switch (this) {
    HomeTutorialStepId.search => l10n.homeTutorialSearchTitle,
    HomeTutorialStepId.filters => l10n.homeTutorialFiltersTitle,
    HomeTutorialStepId.listCard => l10n.homeTutorialListCardTitle,
    HomeTutorialStepId.bottomNav => l10n.homeTutorialBottomNavTitle,
  };

  String body(AppLocalizations l10n) => switch (this) {
    HomeTutorialStepId.search => l10n.homeTutorialSearchBody,
    HomeTutorialStepId.filters => l10n.homeTutorialFiltersBody,
    HomeTutorialStepId.listCard => l10n.homeTutorialListCardBody,
    HomeTutorialStepId.bottomNav => l10n.homeTutorialBottomNavBody,
  };
}
