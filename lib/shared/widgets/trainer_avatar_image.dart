import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';

/// Renders trainer character assets from [assets/images/characters/].
class TrainerAvatarImage extends StatelessWidget {
  const TrainerAvatarImage({
    required this.assetPath,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.errorBuilder,
    this.pixelArt = true,
  });

  TrainerAvatarImage.forSlug({
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

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final ImageErrorWidgetBuilder? errorBuilder;
  final bool pixelArt;

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
