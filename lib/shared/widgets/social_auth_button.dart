import 'package:flutter/material.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';

enum SocialAuthProvider { apple, google, email }

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  final SocialAuthProvider provider;
  final VoidCallback onPressed;

  static const _pillRadius = 28.0;
  static const _height = 52.0;

  static const _socialButtonBackground = Colors.white;
  static const _socialButtonForeground = Color(0xFF1D1D1D);
  static const _socialButtonBorder = Color(0xFFD9D9D9);
  static const _emailButtonBackground = AppColorsLight.primary;
  static const _emailButtonForeground = Colors.white;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _height,
      child: switch (provider) {
        SocialAuthProvider.apple => OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(
            Icons.apple,
            size: 22,
            color: _socialButtonForeground,
          ),
          label: const Text(
            'Continuar com a Apple',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _socialButtonForeground,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: _socialButtonBackground,
            foregroundColor: _socialButtonForeground,
            side: const BorderSide(color: _socialButtonBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_pillRadius),
            ),
          ),
        ),
        SocialAuthProvider.google => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: _socialButtonBackground,
            foregroundColor: _socialButtonForeground,
            side: const BorderSide(color: _socialButtonBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_pillRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoogleGlyph(),
              const SizedBox(width: 10),
              const Text(
                'Continuar com o Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _socialButtonForeground,
                ),
              ),
            ],
          ),
        ),
        SocialAuthProvider.email => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _emailButtonBackground,
            foregroundColor: _emailButtonForeground,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_pillRadius),
            ),
          ),
          child: const Text(
            'Continuar com um e-mail',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      },
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final blue = Paint()..color = const Color(0xFF4285F4);
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.4,
      2.2,
      true,
      blue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.8,
      1.2,
      true,
      green,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.0,
      1.0,
      true,
      yellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      4.0,
      1.4,
      true,
      red,
    );

    final hole = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, hole);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
