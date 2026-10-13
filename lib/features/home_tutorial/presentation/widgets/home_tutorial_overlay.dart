import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/home_tutorial/domain/home_tutorial_step.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/providers/home_tutorial_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Light spotlight overlay for the home tutorial (Skip + Next/Done).
class const HomeTutorialOverlay({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeTutorialOverlay> createState() =>
      _HomeTutorialOverlayState();
}

class _HomeTutorialOverlayState extends ConsumerState<HomeTutorialOverlay> {
  Rect? _hole;
  Timer? _measureTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHole());
  }

  @override
  void dispose() {
    _measureTimer?.cancel();
    super.dispose();
  }

  void _scheduleMeasure() {
    _measureTimer?.cancel();
    _measureTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) _measureHole();
    });
  }

  void _measureHole() {
    final tutorial = ref.read(homeTutorialProvider);
    if (!tutorial.isActive) return;

    final key = ref.read(homeTutorialKeysProvider).keyFor(tutorial.currentStep);
    final rect = _rectForKey(key);
    if (!mounted) return;
    if (rect == _hole) return;
    setState(() => _hole = rect);
  }

  Rect? _rectForKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = ref.watch(homeTutorialProvider);
    if (!tutorial.isActive) return const SizedBox.shrink();

    ref.listen(homeTutorialProvider, (prev, next) {
      if (prev?.stepIndex != next.stepIndex ||
          prev?.isActive != next.isActive) {
        _scheduleMeasure();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHole());

    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final step = tutorial.currentStep;
    final hole = _hole?.inflate(8);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SpotlightPainter(hole: hole),
              child: const SizedBox.expand(),
            ),
          ),
          // Absorb taps on the dimmed area so the tour stays intentional,
          // while Skip remains available (does not hard-block leaving).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          _TooltipCard(
            hole: hole,
            screenSize: media.size,
            padding: media.padding,
            title: step.title(l10n),
            body: step.body(l10n),
            stepLabel: l10n.homeTutorialStepLabel(
              tutorial.stepIndex + 1,
              HomeTutorialStepId.values.length,
            ),
            skipLabel: l10n.homeTutorialSkipButton,
            nextLabel: tutorial.isLastStep
                ? l10n.homeTutorialDoneButton
                : l10n.homeTutorialNextButton,
            onSkip: () => unawaited(
              ref.read(homeTutorialProvider.notifier).skip(),
            ),
            onNext: () => unawaited(
              ref.read(homeTutorialProvider.notifier).next(),
            ),
          ),
        ],
      ),
    );
  }
}

class const _TooltipCard({
  required final Rect? hole,
  required final Size screenSize,
  required final EdgeInsets padding,
  required final String title,
  required final String body,
  required final String stepLabel,
  required final String skipLabel,
  required final String nextLabel,
  required final VoidCallback onSkip,
  required final VoidCallback onNext,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const cardMaxWidth = 340.0;
    const estimatedCardHeight = 168.0;
    const horizontal = 16.0;

    final highlight = hole;
    final double top;
    if (highlight == null) {
      top = screenSize.height * 0.35;
    } else {
      final below = highlight.bottom + 16;
      final above = highlight.top - estimatedCardHeight - 16;
      final fitsBelow =
          below + estimatedCardHeight < screenSize.height - padding.bottom - 8;
      top = fitsBelow
          ? below
          : above.clamp(padding.top + 8, screenSize.height);
    }

    return Positioned(
      top: top.clamp(padding.top + 8, screenSize.height - 120),
      left: horizontal,
      right: horizontal,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: cardMaxWidth),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    stepLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
                      ),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onSkip,
                        child: Text(skipLabel),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColorsLight.primary,
                        ),
                        child: Text(nextLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter({required final Rect? hole}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Offset.zero & size);
    final highlight = hole;
    if (highlight != null) {
      overlay
        ..addRRect(
          RRect.fromRectAndRadius(highlight, const Radius.circular(14)),
        )
        ..fillType = PathFillType.evenOdd;
    }

    canvas.drawPath(
      overlay,
      Paint()..color = Colors.black.withValues(alpha: 0.42),
    );

    if (highlight != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(highlight, const Radius.circular(14)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.hole != hole;
  }
}
