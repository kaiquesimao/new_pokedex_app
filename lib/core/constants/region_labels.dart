abstract final class RegionLabels {
  static const Map<String, String> displayNames = {
    'kanto': 'Kanto',
    'johto': 'Johto',
    'hoenn': 'Hoenn',
    'sinnoh': 'Sinnoh',
    'unova': 'Unova',
    'kalos': 'Kalos',
    'alola': 'Alola',
    'galar': 'Galar',
    'paldea': 'Paldea',
    'hisui': 'Hisui',
    'kitakami': 'Kitakami',
    'blueberry': 'Blueberry',
  };

  static String label(String apiName) {
    return displayNames[apiName] ?? _capitalize(apiName);
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
