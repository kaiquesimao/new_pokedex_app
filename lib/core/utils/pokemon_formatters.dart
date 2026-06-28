/// Shared Pokémon national dex number formatting.
abstract final class PokemonFormatters {
  /// e.g. `25` → `Nº025`.
  static String displayNumber(int id) => 'Nº${id.toString().padLeft(3, '0')}';
}
