import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _horizontalInset = 16.0;
  static const _bottomInset = 12.0;
  static const _barHeightWeb = 72.0;
  static const _barHeightMobile = 64.0;

  /// Bottom space taken by the floating nav over [Scaffold.extendBody].
  static double overlayHeight(BuildContext context) {
    const barHeight = kIsWeb ? _barHeightWeb : _barHeightMobile;
    // Leave a little of the floating gap free so lists feel tighter.
    return barHeight + MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    const isWeb = kIsWeb;
    final labels = [
      l10n.navPokedex,
      l10n.navRegions,
      l10n.navFavorites,
      l10n.navAccount,
    ];
    const barHeight = isWeb ? _barHeightWeb : _barHeightMobile;
    const itemWidth = isWeb ? 96.0 : 72.0;
    const iconSize = isWeb ? 32.0 : 26.0;
    final labelStyle =
        (isWeb ? theme.textTheme.labelMedium : theme.textTheme.labelSmall)
            ?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
    final bottomGap = _bottomInset + MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalInset,
        0,
        _horizontalInset,
        bottomGap,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 1,
        shadowColor: theme.shadowColor.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.18),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: barHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(labels.length, (index) {
              final selected = currentIndex == index;
              return SizedBox(
                width: itemWidth,
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NavIcon(
                        index: index,
                        selected: selected,
                        size: iconSize,
                      ),
                      if (selected) ...[
                        const SizedBox(height: isWeb ? 6 : 4),
                        Text(
                          labels[index],
                          style: labelStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.index,
    required this.selected,
    required this.size,
  });

  final int index;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.45);
    final color = selected ? primary : muted;

    final asset = switch (index) {
      0 => selected ? AppAssets.navPokedexActive : AppAssets.navPokedexInactive,
      1 => selected ? AppAssets.navRegionsActive : AppAssets.navRegionsInactive,
      2 =>
        selected
            ? AppAssets.navFavoritesActive
            : AppAssets.navFavoritesInactive,
      _ => selected ? AppAssets.navProfileActive : AppAssets.navProfileInactive,
    };

    final fallback = switch (index) {
      0 => Icons.catching_pokemon,
      1 => Icons.public,
      2 => Icons.favorite_border,
      _ => Icons.person_outline,
    };

    return AnimatedScale(
      scale: selected ? 1.1 : 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: selected ? 1 : 0.75,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: SvgPicture.asset(
          asset,
          width: size,
          height: size,
          placeholderBuilder: (_) => Icon(fallback, color: color, size: size),
        ),
      ),
    );
  }
}
