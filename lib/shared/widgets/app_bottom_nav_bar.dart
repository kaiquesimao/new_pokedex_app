import 'package:curved_navigation_bar_pro/curved_navigation_bar_pro.dart';
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

  // Compact geometry: sunk surface-matched FAB, shorter bar.
  static const double barHeight = 72;
  static const double fabRadius = 20;
  static const double fabGap = 4;
  static const double fabSink = 20;
  static const double _inactiveIconSize = 28;
  static const double _activeIconSize = 32;
  static const double _horizontalInset = 16;
  static const double _bottomInset = 12;
  static const double _cornerRadius = 20;

  /// Bottom space taken by the floating nav over [Scaffold.extendBody].
  static double overlayHeight(BuildContext context) {
    return barHeight +
        _bottomInset +
        MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final inactive = scheme.onSurface.withValues(alpha: 0.45);
    final bottomGap = _bottomInset + MediaQuery.paddingOf(context).bottom;

    final labels = [
      l10n.navPokedex,
      l10n.navRegions,
      l10n.navFavorites,
      l10n.navAccount,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalInset,
        0,
        _horizontalInset,
        bottomGap,
      ),
      // Package GestureDetectors omit mouseCursor; whole bar is a hit target.
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_cornerRadius),
          child: CurvedNavigationBarPro(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: scheme.surface,
            activeColor: scheme.primary,
            // Match bar so the package disc is invisible (no accent circle).
            fabColor: scheme.surface,
            inactiveColor: inactive,
            barHeight: barHeight,
            fabRadius: fabRadius,
            fabGap: fabGap,
            fabSink: fabSink,
            cornerRadius: _cornerRadius,
            inactiveIconSize: _inactiveIconSize,
            activeIconSize: _activeIconSize,
            showLabel: true,
            // Collapse inactive labels; package AnimatedDefaultTextStyle fades
            // them in.
            inactiveTextStyle: const TextStyle(
              fontSize: 0,
              height: 0,
              color: Colors.transparent,
            ),
            activeTextStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              height: 1.1,
            ),
            items: [
              for (var i = 0; i < labels.length; i++)
                CurvedNavigationItemPro(
                  label: labels[i],
                  activeWidget: _NavSvg(
                    index: i,
                    selected: true,
                    size: _activeIconSize,
                  ),
                  inactiveWidget: _NavSvg(
                    index: i,
                    selected: false,
                    size: _inactiveIconSize,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSvg extends StatelessWidget {
  const _NavSvg({
    required this.index,
    required this.selected,
    required this.size,
  });

  final int index;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.45);

    final asset = switch (index) {
      0 => selected ? AppAssets.navPokedexActive : AppAssets.navPokedexInactive,
      1 => selected ? AppAssets.navRegionsActive : AppAssets.navRegionsInactive,
      2 => selected
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

    // ponytail: assets already have active/inactive variants; no colorFilter.
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      placeholderBuilder: (_) => Icon(fallback, color: color, size: size),
    );
  }
}
