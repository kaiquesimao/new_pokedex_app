import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/auth_web_action_metrics.dart';

enum AppButtonVariant { filled, outline, disabled }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled =
        variant == AppButtonVariant.disabled || onPressed == null;

    final backgroundColor = switch (variant) {
      AppButtonVariant.filled => theme.colorScheme.primary,
      AppButtonVariant.outline => theme.colorScheme.surface,
      AppButtonVariant.disabled => theme.disabledColor,
    };

    final foregroundColor = switch (variant) {
      AppButtonVariant.filled => Colors.white,
      AppButtonVariant.outline => theme.colorScheme.primary,
      AppButtonVariant.disabled => theme.colorScheme.onSurface.withValues(
        alpha: 0.4,
      ),
    };

    const buttonHeight = kIsWeb ? AuthWebActionMetrics.buttonHeight : 52.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: variant == AppButtonVariant.filled ? 2 : 0,
          side: variant == AppButtonVariant.outline
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: kIsWeb ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Text action with an opaque surface background for readability on imagery.
class AppSurfaceTextButton extends StatelessWidget {
  const AppSurfaceTextButton({
    required this.label,
    super.key,
    this.onPressed,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconAlignment iconAlignment;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.primary;
    const buttonHeight = kIsWeb ? AuthWebActionMetrics.buttonHeight : 52.0;
    final radius = expand ? buttonHeight / 2 : 26.0;
    final labelStyle = TextStyle(
      color: foreground,
      fontWeight: FontWeight.w600,
      fontSize: kIsWeb ? 14 : 15,
    );

    final content = icon == null
        ? Text(label, style: labelStyle, textAlign: TextAlign.center)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: iconAlignment == IconAlignment.end
                ? [
                    Text(label, style: labelStyle),
                    const SizedBox(width: 6),
                    Icon(icon, size: 18, color: foreground),
                  ]
                : [
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: 6),
                    Text(label, style: labelStyle),
                  ],
          );

    final button = Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: expand
            ? SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: Center(child: content),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: content,
              ),
      ),
    );

    if (expand) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: button,
      );
    }
    return IntrinsicWidth(child: button);
  }
}
