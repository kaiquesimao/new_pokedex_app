import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _labels = ['PokeData', 'Regiões', 'Favoritos', 'Conta'];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      height: 72,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: List.generate(_labels.length, (index) {
        final selected = currentIndex == index;
        return NavigationDestination(
          icon: _NavIcon(index: index, selected: selected),
          selectedIcon: _NavIcon(index: index, selected: true),
          label: _labels[index],
        );
      }),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.index, required this.selected});

  final int index;
  final bool selected;

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
          width: 26,
          height: 26,
          placeholderBuilder: (_) => Icon(fallback, color: color, size: 26),
        ),
      ),
    );
  }
}
