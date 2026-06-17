import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.5),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PokemonTypeIcon(assetPath: type.assetPath),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                _label(type),
                style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _label(PokemonType type) => type.labelPt;
}
