import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

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
      label: AppLocalizations.of(context).pokemonImageLoadingSemantics,
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

class PokemonSpriteImage extends StatefulWidget {
  const PokemonSpriteImage({
    required this.imageUrl,
    super.key,
    this.fallbackImageUrl,
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
  final String? fallbackImageUrl;
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
  State<PokemonSpriteImage> createState() => _PokemonSpriteImageState();
}

class _PokemonSpriteImageState extends State<PokemonSpriteImage> {
  late String _currentUrl;
  var _usedFallback = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(covariant PokemonSpriteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackImageUrl != widget.fallbackImageUrl) {
      _currentUrl = widget.imageUrl;
      _usedFallback = false;
    }
  }

  String? get _fallbackUrl =>
      widget.fallbackImageUrl ??
      PokemonSpriteUrls.officialArtworkFallbackFor(widget.imageUrl);

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final logicalSize = _logicalCacheSize();
    final cacheSize = logicalSize == null
        ? null
        : cachePixelSize(
            logicalSize,
            devicePixelRatio,
            maxPixels: widget.maxCachePixels,
          );

    Widget buildLoadingIndicator(BuildContext context) {
      return PokemonSpriteLoadingPlaceholder(
        width: widget.width,
        height: widget.height,
        indicatorColor: widget.errorIconColor?.withValues(alpha: 0.7),
      );
    }

    Widget buildErrorWidget(BuildContext context) {
      final fallback = _fallbackUrl;
      if (!_usedFallback && fallback != null && fallback != _currentUrl) {
        _usedFallback = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _currentUrl = fallback);
        });
        return buildLoadingIndicator(context);
      }

      return Icon(
        Icons.catching_pokemon,
        size: widget.errorIconSize,
        color: widget.errorIconColor,
      );
    }

    Widget image = CachedNetworkImage(
      key: ValueKey(_currentUrl),
      imageUrl: _currentUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      filterQuality: widget.filterQuality,
      fadeInDuration: widget.fadeInDuration,
      memCacheWidth: cacheSize,
      memCacheHeight: cacheSize,
      progressIndicatorBuilder: (_, _, _) => buildLoadingIndicator(context),
      errorWidget: (_, _, _) => buildErrorWidget(context),
    );

    if (widget.heroTag != null) {
      image = Hero(
        tag: widget.heroTag!,
        child: Material(color: Colors.transparent, child: image),
      );
    }

    if (widget.semanticLabel != null) {
      image = Semantics(label: widget.semanticLabel, image: true, child: image);
    }

    return image;
  }

  double? _logicalCacheSize() {
    if (widget.width != null && widget.height != null) {
      return widget.width! > widget.height! ? widget.width! : widget.height!;
    }
    return widget.width ?? widget.height;
  }
}
