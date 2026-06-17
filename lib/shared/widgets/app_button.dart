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
      AppButtonVariant.outline => Colors.transparent,
      AppButtonVariant.disabled => theme.disabledColor,
    };

    final foregroundColor = switch (variant) {
      AppButtonVariant.filled => Colors.white,
      AppButtonVariant.outline => theme.colorScheme.primary,
      AppButtonVariant.disabled => theme.colorScheme.onSurface.withValues(
        alpha: 0.4,
      ),
    };

    return SizedBox(
      width: double.infinity,
      height: kIsWeb ? AuthWebActionMetrics.buttonHeight : 52,
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
            borderRadius: BorderRadius.circular(kIsWeb ? 24 : 12),
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
