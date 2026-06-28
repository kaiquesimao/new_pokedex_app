abstract final class AppAssets {
  static const String elementsBase = 'assets/images/elements/';
  static const String componentsBase = 'assets/images/components/';
  static const String charactersBase = 'assets/images/characters/';

  // Bottom navigation
  static const String navPokedexActive =
      '${componentsBase}nav_pokedex_active.svg';
  static const String navPokedexInactive =
      '${componentsBase}nav_pokedex_inactive.svg';
  static const String navRegionsActive =
      '${componentsBase}nav_regions_active.svg';
  static const String navRegionsInactive =
      '${componentsBase}nav_regions_inactive.svg';

  static const String navFavoritesActive =
      '${componentsBase}nav_favorites_active.svg';
  static const String navFavoritesInactive =
      '${componentsBase}nav_favorites_inactive.svg';
  static const String navProfileActive =
      '${componentsBase}nav_profile_active.svg';
  static const String navProfileInactive =
      '${componentsBase}nav_profile_inactive.svg';

  // UI actions
  static const String iconGoogle = '${componentsBase}icon_google.svg';

  // Decorative / reference sheets (layout guides from Figma — not used as UI)
  static const String patternMagikarp =
      '${componentsBase}pattern_magikarp.webp';

  // Character sprites (see TrainerAvatars for the full curated list)
  static const String characterBugcatcher = '${charactersBase}bugcatcher.png';
  static const String characterBirch = '${charactersBase}birch.png';
  static const String characterHilda = '${charactersBase}hilda.png';
  static const String characterHilbert = '${charactersBase}hilbert.png';
}
