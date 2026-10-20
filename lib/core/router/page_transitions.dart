import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';

const routeTransitionDuration = Duration(milliseconds: 250);

/// Fades a pushed page in over an opaque scrim so the route underneath cannot
/// show through a transparent scaffold. The scrim fades out at the end of the
/// push, after the shell has already left, so the wide-web backdrop can show.
class DetailPageTransition extends StatelessWidget {
  const new({required this.animation, required this.child, super.key});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scrim = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.background
        : AppColorsLight.background;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final popping = animation.status == AnimationStatus.reverse;
        final scrimOpacity = popping ? 0.0 : pushScrimOpacity(animation.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            if (scrimOpacity > 0)
              Opacity(
                opacity: scrimOpacity,
                child: ColoredBox(color: scrim),
              ),
            Opacity(opacity: routeFadeOpacity(animation), child: child),
          ],
        );
      },
      child: child,
    );
  }
}

/// Fades the shell out while a full-screen route is covering it, and back in
/// on pop. Keeps the list from staying fully opaque under the detail page.
class ShellExitTransition extends StatelessWidget {
  const new({required this.secondaryAnimation, required this.child, super.key});

  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: secondaryAnimation,
      builder: (context, child) {
        final covered = shellCoveredAmount(
          secondaryAnimation.value,
          reversing: secondaryAnimation.status == AnimationStatus.reverse,
        );
        return Opacity(opacity: (1 - covered).clamp(0.0, 1.0), child: child);
      },
      child: child,
    );
  }
}

double routeFadeOpacity(Animation<double> animation) {
  final reverse = animation.status == AnimationStatus.reverse;
  final curve = reverse ? Curves.easeInCubic : Curves.easeOutCubic;
  return curve.transform(animation.value.clamp(0.0, 1.0));
}

/// Opaque while the shell is still leaving, then fades so the backdrop returns.
double pushScrimOpacity(double t) {
  const fadeOutStart = 0.72;
  final progress = t.clamp(0.0, 1.0);
  if (progress <= fadeOutStart) return 1;
  final fade = (progress - fadeOutStart) / (1 - fadeOutStart);
  return 1 - Curves.easeOutCubic.transform(fade);
}

/// 0 = shell fully visible, 1 = shell fully gone.
double shellCoveredAmount(double t, {required bool reversing}) {
  final progress = t.clamp(0.0, 1.0);
  if (!reversing) {
    return Curves.easeOutCubic.transform((progress / 0.5).clamp(0.0, 1.0));
  }

  const returnStart = 0.45;
  if (progress >= returnStart) return 1;
  return Curves.easeOutCubic.transform(
    (progress / returnStart).clamp(0.0, 1.0),
  );
}
