import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/responsive_layout.dart';
import 'package:pokedex_app/core/constants/wide_viewport_backdrop_assets.dart';
import 'package:pokedex_app/shared/widgets/wide_viewport_backdrop_provider.dart';

bool showsWideViewportBackdropFor({
  required bool isWeb,
  required double width,
}) {
  return isWeb && width > ResponsiveLayout.maxContentWidth;
}

bool showsWideViewportBackdrop(BuildContext context) {
  return showsWideViewportBackdropFor(
    isWeb: kIsWeb,
    width: MediaQuery.sizeOf(context).width,
  );
}

Color wideViewportAwareScaffoldColor(BuildContext context) {
  return showsWideViewportBackdrop(context)
      ? Colors.transparent
      : Theme.of(context).colorScheme.surface;
}

/// Transparent scaffold theme on wide web so [WideViewportBackdrop] is visible.
class WideViewportTheme extends StatelessWidget {
  const WideViewportTheme({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!showsWideViewportBackdrop(context)) return child;

    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(scaffoldBackgroundColor: Colors.transparent),
      child: child,
    );
  }
}

/// Decorative backdrop for empty side margins on wide web viewports.
class WideViewportBackdrop extends ConsumerStatefulWidget {
  const WideViewportBackdrop({super.key});

  @override
  ConsumerState<WideViewportBackdrop> createState() =>
      _WideViewportBackdropState();
}

class _WideViewportBackdropState extends ConsumerState<WideViewportBackdrop>
    with WidgetsBindingObserver {
  static const _rotationInterval = Duration(minutes: 3);

  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _rotationTimer = Timer.periodic(_rotationInterval, (_) {
      if (!mounted) return;
      ref.read(wideViewportBackdropIndexProvider.notifier).rotateRandom();
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(wideViewportBackdropIndexProvider.notifier).rotateRandom();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    if (width <= ResponsiveLayout.maxContentWidth) {
      return const SizedBox.shrink();
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final index = ref.watch(wideViewportBackdropIndexProvider);
    final asset = WideViewportBackdropAssets.paths[index];
    final surface = Theme.of(context).colorScheme.surface;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 900);

    return IgnorePointer(
      child: ColoredBox(
        color: surface,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: duration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _BackdropImage(
                key: ValueKey(asset),
                assetPath: asset,
                reduceMotion: reduceMotion,
              ),
            ),
            ColoredBox(color: surface.withValues(alpha: 0.48)),
          ],
        ),
      ),
    );
  }
}

class _BackdropImage extends StatelessWidget {
  const _BackdropImage({
    required this.assetPath,
    required this.reduceMotion,
    super.key,
  });

  final String assetPath;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final image = Opacity(
      opacity: 0.48,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
      ),
    );

    if (reduceMotion) return image;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: image,
    );
  }
}
