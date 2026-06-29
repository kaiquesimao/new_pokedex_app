import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';

/// Faded white type icon centered behind a Pokémon sprite.
class PokemonPrimaryTypeBackdrop extends StatelessWidget {
  const PokemonPrimaryTypeBackdrop({
    required this.type,
    super.key,
    this.size = listRowSize,
    this.opacity = 0.35,
  });

  final PokemonType type;
  final double size;
  final double opacity;

  static const double listRowSize = 100;
  static const double detailSize = 230;
  static const double detailOpacity = 0.3;
  static const double detailLightOpacity = 0.38;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: SizedBox(
          width: size,
          height: size,
          child: FittedBox(
            child: SvgPicture.asset(
              type.assetPath,
              placeholderBuilder: (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
