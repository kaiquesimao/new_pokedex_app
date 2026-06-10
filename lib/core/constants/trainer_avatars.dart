abstract final class TrainerAvatars {
  static const String defaultSlug = 'ash';
  static const String assetsBase = 'assets/images/characters/';

  static const List<TrainerAvatarOption> curated = [
    TrainerAvatarOption(slug: 'ash', label: 'Ash', fileName: 'ash.png'),
    TrainerAvatarOption(slug: 'hilda', label: 'Hilda', fileName: 'hilda.png'),
    TrainerAvatarOption(
      slug: 'hilbert',
      label: 'Hilbert',
      fileName: 'hilbert.png',
    ),
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
      slug: 'lucian',
      label: 'Lucian',
      fileName: 'lucian.png',
    ),
    TrainerAvatarOption(slug: 'volo', label: 'Volo', fileName: 'volo.png'),
    TrainerAvatarOption(
      slug: 'professor_birch',
      label: 'Prof. Birch',
      fileName: 'professor_birch.png',
    ),
    TrainerAvatarOption(
      slug: 'bug_catcher',
      label: 'Caçador de Insetos',
      fileName: 'bug_catcher.png',
    ),
    TrainerAvatarOption(
      slug: 'trainer_red',
      label: 'Treinador',
      fileName: 'trainer_red.png',
    ),
    TrainerAvatarOption(
      slug: 'trainer_silver',
      label: 'Treinador',
      fileName: 'trainer_silver.png',
    ),
    TrainerAvatarOption(
      slug: 'rhydon_costume',
      label: 'Fantasia Rhydon',
      fileName: 'rhydon_costume.png',
    ),
    TrainerAvatarOption(
      slug: 'miku_trainer',
      label: 'Miku',
      fileName: 'miku_trainer.png',
    ),
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
