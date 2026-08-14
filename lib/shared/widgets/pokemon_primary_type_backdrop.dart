import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';

/// Faded white type icon centered behind a Pokémon sprite.
class const PokemonPrimaryTypeBackdrop({
  required final PokemonType type,
  super.key,
  final double size = listRowSize,
  final double opacity = 0.35,
}) extends StatelessWidget {
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
