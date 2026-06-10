abstract final class AppAssets {
  static const String elementsBase = 'assets/images/elements/';
  static const String componentsBase = 'assets/images/components/';
  static const String charactersBase = 'assets/images/characters/';

  // Bottom navigation — Pokédex & Regiões (custom pixel art)
  static const String navPokedexActive =
      '${componentsBase}nav_pokedex_active.png';
  static const String navPokedexInactive =
      '${componentsBase}nav_pokedex_inactive.png';
  static const String navRegionsActive =
      '${componentsBase}nav_regions_active.png';
  static const String navRegionsInactive =
      '${componentsBase}nav_regions_inactive.png';

  static const String navFavoritesActive =
      '${componentsBase}nav_favorites_active.png';
  static const String navFavoritesInactive =
      '${componentsBase}nav_favorites_inactive.png';
  static const String navProfileActive =
      '${componentsBase}nav_profile_active.png';
  static const String navProfileInactive =
      '${componentsBase}nav_profile_inactive.png';

  // UI actions
  static const String iconSearch = '${componentsBase}icon_search.png';
  static const String iconBackChevron =
      '${componentsBase}icon_back_chevron.png';
  static const String iconBackArrow = '${componentsBase}icon_back_arrow.png';
  static const String iconTrash = '${componentsBase}icon_trash.png';

  // Password visibility toggle
  static const String passwordEyeOpen =
      '${componentsBase}password_eye_open.png';
  static const String passwordEyeClosed =
      '${componentsBase}password_eye_closed.png';

  // Decorative / reference sheets (layout guides from Figma — not used as UI)
  static const String patternMagikarp = '${componentsBase}pattern_magikarp.png';
  static const String refTypeChips = '${componentsBase}ref_type_chips.png';
  static const String refTabBarSheet = '${componentsBase}ref_tab_bar_sheet.png';

  // Trainer sprites (see TrainerAvatars for the full curated list)
  static const String trainerAsh = '${charactersBase}ash.png';
}
