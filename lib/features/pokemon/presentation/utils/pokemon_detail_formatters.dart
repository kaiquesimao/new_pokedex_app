abstract final class PokemonDetailFormatters {
  static String decimal(double value) =>
      value.toStringAsFixed(1).replaceAll('.', ',');

  static String statLabel(String apiName) {
    return switch (apiName) {
      'hp' => 'HP',
      'attack' => 'Ataque',
      'defense' => 'Defesa',
      'special-attack' => 'Atq. Esp.',
      'special-defense' => 'Def. Esp.',
      'speed' => 'Velocidade',
      _ => _formatName(apiName),
    };
  }

  static String abilityLabel(String apiName, {required bool isHidden}) {
    final name = _formatName(apiName);
    return isHidden ? '$name (oculta)' : name;
  }

  /// PokeAPI `gender_rate` uses steps of 12.5% (0–8), not 0–255.
  static double femalePercent(int genderRate) {
    if (genderRate <= 0) return 0;
    if (genderRate >= 8 || genderRate == 254) return 100;
    return genderRate * 12.5;
  }

  static double malePercent(int genderRate) => 100 - femalePercent(genderRate);

  static String genderLabel(int genderRate) {
    if (genderRate < 0) return 'Sem gênero';
    if (genderRate == 0) return 'Somente macho';
    if (genderRate >= 8 || genderRate == 254) return 'Somente fêmea';
    return '${decimal(femalePercent(genderRate))}% fêmea';
  }

  static String eggGroupsLabel(List<String> eggGroups) {
    return eggGroups.map(_formatName).join(', ');
  }

  static String hatchSteps(int hatchCounter) {
    if (hatchCounter <= 0) return 'Não choca de ovo';
    return '${hatchCounter * 255} passos';
  }

  static String _formatName(String value) {
    return value
        .split('-')
        .map((part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1);
        })
        .join(' ');
  }
}
