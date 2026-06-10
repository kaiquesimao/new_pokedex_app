class ProfileSettings {
  const ProfileSettings({
    this.showMegaEvolutions = true,
    this.showOtherForms = true,
    this.notifyNewPokemon = true,
    this.notifyAppUpdates = false,
    this.interfaceLanguage = 'pt-BR',
    this.gameInfoLanguage = 'en-US',
  });

  final bool showMegaEvolutions;
  final bool showOtherForms;
  final bool notifyNewPokemon;
  final bool notifyAppUpdates;
  final String interfaceLanguage;
  final String gameInfoLanguage;

  static const appVersion = '0.8.12';

  ProfileSettings copyWith({
    bool? showMegaEvolutions,
    bool? showOtherForms,
    bool? notifyNewPokemon,
    bool? notifyAppUpdates,
    String? interfaceLanguage,
    String? gameInfoLanguage,
  }) {
    return ProfileSettings(
      showMegaEvolutions: showMegaEvolutions ?? this.showMegaEvolutions,
      showOtherForms: showOtherForms ?? this.showOtherForms,
      notifyNewPokemon: notifyNewPokemon ?? this.notifyNewPokemon,
      notifyAppUpdates: notifyAppUpdates ?? this.notifyAppUpdates,
      interfaceLanguage: interfaceLanguage ?? this.interfaceLanguage,
      gameInfoLanguage: gameInfoLanguage ?? this.gameInfoLanguage,
    );
  }

  String get interfaceLanguageLabel =>
      interfaceLanguage == 'pt-BR' ? 'PT-BR' : 'EN-US';

  String get gameInfoLanguageLabel =>
      gameInfoLanguage == 'pt-BR' ? 'PT-BR' : 'EN-US';
}
