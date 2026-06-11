import 'package:flutter/material.dart';

class PokemonStatBar extends StatelessWidget {
  const PokemonStatBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    this.color,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? theme.colorScheme.primary;
    final fraction = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value.toString().padLeft(3, '0'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: barColor.withValues(alpha: 0.2),
                color: barColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
