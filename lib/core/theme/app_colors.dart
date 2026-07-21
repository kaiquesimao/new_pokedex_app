import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';

abstract final class AppColorsLight {
  static const Color background = Color(0xFFEFEFEF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF666666);
  static const Color primary = Color(0xFF173EA5);
  static const Color genderFemale = Color(0xFFE94B7B);
  static const Color splashNavy = Color(0xFF0D1B2A);
  static const Color sortPillDark = Color(0xFF1A1A1A);
  static const Color pokedexRed = Color(0xFFE3350D);
}

abstract final class AppColorsDark {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color primary = Color(0xFF173EA5);
}

abstract final class PokemonTypeColors {
  static const Map<PokemonType, Color> light = {
    PokemonType.normal: Color(0xFFAAB09F),
    PokemonType.fire: Color(0xFFEA7A3C),
    PokemonType.water: Color(0xFF539AE2),
    PokemonType.grass: Color(0xFF71C558),
    PokemonType.electric: Color(0xFFE5C531),
    PokemonType.ice: Color(0xFF70CBD4),
    PokemonType.fighting: Color(0xFFCB5F48),
    PokemonType.poison: Color(0xFFB468B7),
    PokemonType.ground: Color(0xFFCC9F4F),
    PokemonType.flying: Color(0xFF7DA6DE),
    PokemonType.psychic: Color(0xFFE5709B),
    PokemonType.bug: Color(0xFF94BC4A),
    PokemonType.rock: Color(0xFFB2A061),
    PokemonType.ghost: Color(0xFF846AB6),
    PokemonType.dragon: Color(0xFF6A7BAF),
    PokemonType.dark: Color(0xFF736C75),
    PokemonType.steel: Color(0xFF89A1B0),
    PokemonType.fairy: Color(0xFFE397D1),
  };

  static Color forType(PokemonType type, {bool isDark = false}) {
    final color = light[type] ?? AppColorsLight.primary;
    if (!isDark) return color;
    return Color.lerp(color, Colors.black, 0.25) ?? color;
  }
}
