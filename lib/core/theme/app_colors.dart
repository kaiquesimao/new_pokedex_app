import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';

abstract final class AppColorsLight {
  static const Color background = Color(0xFFEFEFEF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF666666);
  static const Color primary = Color(0xFF1D3B74);
  static const Color splashNavy = Color(0xFF0D1B2A);
  static const Color sortPillDark = Color(0xFF1A1A1A);
  static const Color pokedexRed = Color(0xFFE3350D);
}

abstract final class AppColorsDark {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color primary = Color(0xFFA0BAFF);
}

abstract final class PokemonTypeColors {
  static const Map<PokemonType, Color> light = {
    PokemonType.normal: Color(0xFFA8A878),
    PokemonType.fire: Color(0xFFF08030),
    PokemonType.water: Color(0xFF6890F0),
    PokemonType.grass: Color(0xFF78C850),
    PokemonType.electric: Color(0xFFF8D030),
    PokemonType.ice: Color(0xFF98D8D8),
    PokemonType.fighting: Color(0xFFC03028),
    PokemonType.poison: Color(0xFFA040A0),
    PokemonType.ground: Color(0xFFE0C068),
    PokemonType.flying: Color(0xFFA890F0),
    PokemonType.psychic: Color(0xFFF85888),
    PokemonType.bug: Color(0xFFA8B820),
    PokemonType.rock: Color(0xFFB8A038),
    PokemonType.ghost: Color(0xFF705898),
    PokemonType.dragon: Color(0xFF7038F8),
    PokemonType.dark: Color(0xFF705848),
    PokemonType.steel: Color(0xFFB8B8D0),
    PokemonType.fairy: Color(0xFFEE99AC),
  };

  static Color forType(PokemonType type, {bool isDark = false}) {
    final color = light[type] ?? AppColorsLight.primary;
    if (!isDark) return color;
    return Color.lerp(color, Colors.black, 0.25) ?? color;
  }
}
