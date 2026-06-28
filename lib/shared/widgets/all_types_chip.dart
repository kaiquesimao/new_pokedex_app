import 'package:flutter/material.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';

class AllTypesChip extends StatelessWidget {
  const AllTypesChip({
    required this.selected,
    required this.onTap,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const pillColor = AppColorsLight.sortPillDark;

    final backgroundColor = selected
        ? pillColor
        : isDark
        ? theme.colorScheme.surface
        : pillColor.withValues(alpha: 0.15);

    final borderColor = selected
        ? pillColor
        : isDark
        ? theme.colorScheme.outline.withValues(alpha: 0.4)
        : pillColor.withValues(alpha: 0.4);

    final textColor = selected
        ? Colors.white
        : isDark
        ? theme.colorScheme.onSurface
        : pillColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          'Todos os tipos',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
