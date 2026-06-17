import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PokemonTypeIcon extends StatelessWidget {
  const PokemonTypeIcon({required this.assetPath, super.key, this.size = 18});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      placeholderBuilder: (_) => SizedBox(width: size, height: size),
    );
  }
}
