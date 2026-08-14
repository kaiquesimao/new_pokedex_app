import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';

/// Renders trainer character assets from [assets/images/characters/].
class const TrainerAvatarImage({
  required final String assetPath,
  super.key,
  final double? width,
  final double? height,
  final BoxFit fit = BoxFit.contain,
  final Alignment alignment = Alignment.center,
  final ImageErrorWidgetBuilder? errorBuilder,
  final bool pixelArt = true,
}) extends StatelessWidget {
  new forSlug({
    required String slug,
    required double size,
    Key? key,
    BoxFit fit = BoxFit.contain,
    bool pixelArt = true,
  }) : this(
         key: key,
         assetPath: TrainerAvatars.assetPathFor(slug),
         width: size,
         height: size,
         fit: fit,
         pixelArt: pixelArt,
         errorBuilder: (_, _, _) => Icon(Icons.person, size: size * 0.8),
       );

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: pixelArt ? FilterQuality.none : FilterQuality.medium,
      errorBuilder: errorBuilder,
    );
  }
}
