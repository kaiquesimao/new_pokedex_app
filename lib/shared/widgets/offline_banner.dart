import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.message =
        'Você está offline. Mostrando Pokémon salvos no dispositivo.',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.secondaryContainer.withValues(alpha: 0.95),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: compact ? 10 : 12,
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: colors.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps the entire app so the offline banner stays fixed above all routes.
class AppOfflineShell extends ConsumerWidget {
  const AppOfflineShell({required this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const ConnectivityOfflineBanner(compact: true),
        Expanded(child: child ?? const SizedBox.shrink()),
      ],
    );
  }
}

class ConnectivityOfflineBanner extends ConsumerWidget {
  const ConnectivityOfflineBanner({
    super.key,
    this.message =
        'Você está offline. Mostrando Pokémon salvos no dispositivo.',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isDeviceOnlineProvider);
    if (isOnline) return const SizedBox.shrink();
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: OfflineBanner(message: message, compact: compact),
    );
  }
}

class OfflineEmptyState extends StatelessWidget {
  const OfflineEmptyState({
    required this.message,
    required this.onRetry,
    super.key,
    this.isConnectivityFailure = true,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isConnectivityFailure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = isConnectivityFailure ? 'Sem conexão' : 'Erro ao carregar';
    final icon = isConnectivityFailure
        ? Icons.cloud_off_outlined
        : Icons.error_outline_rounded;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(icon, size: 52, color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
