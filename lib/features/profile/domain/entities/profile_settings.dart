class ProfileSettings {
  const ProfileSettings({
    this.showMegaEvolutions = true,
    this.showOtherForms = true,
    this.notifyNewPokemon = true,
    this.notifyAppUpdates = false,
    this.appLanguage = 'pt-BR',
  });

  final bool showMegaEvolutions;
  final bool showOtherForms;
  final bool notifyNewPokemon;
  final bool notifyAppUpdates;
  final String appLanguage;

  ProfileSettings copyWith({
    bool? showMegaEvolutions,
    bool? showOtherForms,
    bool? notifyNewPokemon,
    bool? notifyAppUpdates,
    String? appLanguage,
  }) {
    return ProfileSettings(
      showMegaEvolutions: showMegaEvolutions ?? this.showMegaEvolutions,
      showOtherForms: showOtherForms ?? this.showOtherForms,
      notifyNewPokemon: notifyNewPokemon ?? this.notifyNewPokemon,
      notifyAppUpdates: notifyAppUpdates ?? this.notifyAppUpdates,
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }

  String get appLanguageLabel => appLanguage == 'pt-BR' ? 'PT-BR' : 'EN-US';
}
