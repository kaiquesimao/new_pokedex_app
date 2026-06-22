abstract final class TrainerAvatars {
  static const String defaultSlug = 'hilbert';
  static const String assetsBase = 'assets/images/characters/';

  static const List<TrainerAvatarOption> curated = [
    TrainerAvatarOption(
      slug: 'hilbert',
      label: 'Hilbert',
      fileName: 'hilbert.png',
    ),
    TrainerAvatarOption(slug: 'hilda', label: 'Hilda', fileName: 'hilda.png'),
    TrainerAvatarOption(slug: 'blue', label: 'Blue', fileName: 'blue.png'),
    TrainerAvatarOption(
      slug: 'cynthia',
      label: 'Cynthia',
      fileName: 'cynthia.png',
    ),
    TrainerAvatarOption(
      slug: 'wallace',
      label: 'Wallace',
      fileName: 'wallace.png',
    ),
    TrainerAvatarOption(
      slug: 'wallace_gen6',
      label: 'Wallace',
      fileName: 'wallace-gen6.png',
    ),
    TrainerAvatarOption(
      slug: 'lucian',
      label: 'Lucian',
      fileName: 'lucian.png',
    ),
    TrainerAvatarOption(
      slug: 'victor',
      label: 'Victor',
      fileName: 'victor.png',
    ),
    TrainerAvatarOption(
      slug: 'birch',
      label: 'Prof. Birch',
      fileName: 'birch.png',
    ),
    TrainerAvatarOption(
      slug: 'bugcatcher',
      label: 'Caçador de Insetos',
      fileName: 'bugcatcher.png',
    ),
    TrainerAvatarOption(
      slug: 'pokemaniac',
      label: 'Pokémaníaco',
      fileName: 'pokemaniac.png',
    ),
    TrainerAvatarOption(slug: 'miku', label: 'Miku', fileName: 'miku.png'),
  ];

  static String assetPathFor(String slug) {
    final match = curated.where((option) => option.slug == slug);
    if (match.isNotEmpty) return match.first.assetPath;
    return curated.first.assetPath;
  }

  static String labelFor(String slug) {
    final match = curated.where((option) => option.slug == slug);
    if (match.isNotEmpty) return match.first.label;
    return curated.first.label;
  }
}

class TrainerAvatarOption {
  const TrainerAvatarOption({
    required this.slug,
    required this.label,
    required this.fileName,
  });

  final String slug;
  final String label;
  final String fileName;

  String get assetPath => '${TrainerAvatars.assetsBase}$fileName';
}
