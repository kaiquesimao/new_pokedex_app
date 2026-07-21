import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/locale/pokemon_type_l10n.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_icon.dart';

class PokemonTypeChip extends StatelessWidget {
  const PokemonTypeChip({
    required this.type,
    super.key,
    this.selected = false,
    this.onTap,
    this.showLabel = true,
  });

  final PokemonType type;
  final bool selected;
  final VoidCallback? onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = PokemonTypeColors.forType(type, isDark: isDark);

    final chip = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected
                ? (Color.lerp(color, Colors.black, 0.4) ?? color)
                : color,
            width: selected ? 2.5 : 0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PokemonTypeIcon(
              assetPath: type.assetPath,
              color: Colors.white,
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                type.label(AppLocalizations.of(context)),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return chip;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: chip,
    );
  }
}
