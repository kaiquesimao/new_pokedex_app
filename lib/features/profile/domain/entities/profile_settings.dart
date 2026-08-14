class const ProfileSettings({
  final bool notifyNewPokemon = true,
  final bool notifyAppUpdates = false,
  final String appLanguage = 'pt-BR',
}) {
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
