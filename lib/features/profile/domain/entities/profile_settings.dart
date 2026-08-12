class ProfileSettings {
  const ProfileSettings({
    this.notifyNewPokemon = true,
    this.notifyAppUpdates = false,
    this.appLanguage = 'pt-BR',
  });

  final bool notifyNewPokemon;
  final bool notifyAppUpdates;
  final String appLanguage;

  ProfileSettings copyWith({
    bool? notifyNewPokemon,
    bool? notifyAppUpdates,
    String? appLanguage,
  }) {
    return ProfileSettings(
      notifyNewPokemon: notifyNewPokemon ?? this.notifyNewPokemon,
      notifyAppUpdates: notifyAppUpdates ?? this.notifyAppUpdates,
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }

  String get appLanguageLabel => appLanguage == 'pt-BR' ? 'PT-BR' : 'EN-US';
}
