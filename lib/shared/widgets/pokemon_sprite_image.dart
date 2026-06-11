import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';

/// Lightweight native loading indicator sized for [PokemonSpriteImage] slots.
class PokemonSpriteLoadingPlaceholder extends StatelessWidget {
  const PokemonSpriteLoadingPlaceholder({
    super.key,
    this.width,
    this.height,
    this.indicatorColor,
  });

  final double? width;
  final double? height;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    final color =
        indicatorColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
    final indicatorSize = _indicatorSize();

    return Semantics(
      label: 'Loading Pokémon image',
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ),
    );
  }

  double _indicatorSize() {
    final base = width ?? height ?? 48;
    return (base * 0.35).clamp(16, 28);
  }
}

class PokemonSpriteImage extends StatelessWidget {
  const PokemonSpriteImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.maxCachePixels = 256,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.high,
    this.heroTag,
    this.semanticLabel,
    this.errorIconSize = 48,
    this.errorIconColor,
    this.fadeInDuration = Duration.zero,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final int maxCachePixels;
  final BoxFit fit;
  final FilterQuality filterQuality;
  final Object? heroTag;
  final String? semanticLabel;
  final double errorIconSize;
  final Color? errorIconColor;
  final Duration fadeInDuration;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final logicalSize = _logicalCacheSize();
    final cacheSize = logicalSize == null
        ? null
        : cachePixelSize(
            logicalSize,
            devicePixelRatio,
            maxPixels: maxCachePixels,
          );

    Widget buildLoadingIndicator(BuildContext context) {
      return PokemonSpriteLoadingPlaceholder(
        width: width,
        height: height,
        indicatorColor: errorIconColor?.withValues(alpha: 0.7),
      );
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      filterQuality: filterQuality,
      fadeInDuration: fadeInDuration,
      memCacheWidth: cacheSize,
      memCacheHeight: cacheSize,
      progressIndicatorBuilder: (_, _, _) => buildLoadingIndicator(context),
      errorWidget: (_, _, _) => Icon(
        Icons.catching_pokemon,
        size: errorIconSize,
        color: errorIconColor,
      ),
    );

    if (heroTag != null) {
      image = Hero(
        tag: heroTag!,
        child: Material(color: Colors.transparent, child: image),
      );
    }

    if (semanticLabel != null) {
      image = Semantics(label: semanticLabel, image: true, child: image);
    }

    return image;
  }

  double? _logicalCacheSize() {
    if (width != null && height != null) {
      return width! > height! ? width! : height!;
    }
    return width ?? height;
  }
}
