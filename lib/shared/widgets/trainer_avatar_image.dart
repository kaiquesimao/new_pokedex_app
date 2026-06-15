import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';

class TrainerAvatarImage extends StatelessWidget {
  const TrainerAvatarImage({
    super.key,
    required this.slug,
    required this.size,
    this.fit = BoxFit.contain,
  });

  final String slug;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      TrainerAvatars.assetPathFor(slug),
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => Icon(Icons.person, size: size * 0.8),
    );
  }
}
