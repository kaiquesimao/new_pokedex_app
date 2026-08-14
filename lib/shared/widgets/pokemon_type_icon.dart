import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

class const PokemonTypeIcon({
  required final String assetPath,
  super.key,
  final double size = 18,
  final Color? color,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox(width: size, height: size),
    );
  }
}
