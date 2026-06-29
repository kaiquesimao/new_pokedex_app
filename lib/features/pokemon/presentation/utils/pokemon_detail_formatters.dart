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

  static String genderLabel(int genderRate) {
    if (genderRate < 0) return 'Sem gênero';
    if (genderRate == 0) return 'Somente macho';
    if (genderRate == 254) return 'Somente fêmea';
    final femalePercent = (genderRate / 255 * 100).toStringAsFixed(1);
    return '$femalePercent% fêmea';
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
