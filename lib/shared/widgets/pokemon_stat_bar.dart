import 'package:material_ui/material_ui.dart';

class const PokemonStatBar({
  required final String label,
  required final int value,
  required final int maxValue,
  super.key,
  final Color? color,
}) extends StatelessWidget {
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
