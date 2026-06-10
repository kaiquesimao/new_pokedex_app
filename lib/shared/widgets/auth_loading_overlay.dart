import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuthLoadingOverlay extends StatelessWidget {
  const AuthLoadingOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PokeballSpinner(size: 72),
              if (message != null) ...[
                const SizedBox(height: 24),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PokeballSpinner extends StatefulWidget {
  const _PokeballSpinner({required this.size});

  final double size;

  @override
  State<_PokeballSpinner> createState() => _PokeballSpinnerState();
}

class _PokeballSpinnerState extends State<_PokeballSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: const _PokeballPainter(),
      ),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  const _PokeballPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFFE3350D),
    );
    canvas.drawCircle(center, radius, outline);
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      outline,
    );
    canvas.drawCircle(center, radius * 0.22, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius * 0.22, outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
