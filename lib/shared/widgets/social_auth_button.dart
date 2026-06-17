import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/core/constants/auth_web_action_metrics.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';

enum SocialAuthProvider { apple, google, email }

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.provider,
    required this.onPressed,
    super.key,
  });

  final SocialAuthProvider provider;
  final VoidCallback onPressed;

  static const _pillRadius = 28.0;
  static const _height = 52.0;
  static const _webPillRadius = 24.0;
  static const _webFontSize = 14.0;
  static const _webIconSize = 20.0;

  static const Color _socialButtonBackground = Colors.white;
  static const _socialButtonForeground = Color(0xFF1D1D1D);
  static const _socialButtonBorder = Color(0xFFD9D9D9);
  static const Color _emailButtonBackground = AppColorsLight.primary;
  static const Color _emailButtonForeground = Colors.white;

  double get _buttonHeight =>
      kIsWeb ? AuthWebActionMetrics.buttonHeight : _height;

  double get _pillRadiusValue => kIsWeb ? _webPillRadius : _pillRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: switch (provider) {
        SocialAuthProvider.apple => OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(
            Icons.apple,
            size: kIsWeb ? _webIconSize : 22,
            color: _socialButtonForeground,
          ),
          label: const Text(
            'Continuar com a Apple',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: kIsWeb ? _webFontSize : 15,
              fontWeight: FontWeight.w600,
              color: _socialButtonForeground,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: _socialButtonBackground,
            foregroundColor: _socialButtonForeground,
            side: const BorderSide(color: _socialButtonBorder),
            padding: kIsWeb ? const EdgeInsets.symmetric(horizontal: 8) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_pillRadiusValue),
            ),
          ),
        ),
        SocialAuthProvider.google => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: _socialButtonBackground,
            foregroundColor: _socialButtonForeground,
            side: const BorderSide(color: _socialButtonBorder),
            padding: kIsWeb ? const EdgeInsets.symmetric(horizontal: 8) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_pillRadiusValue),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoogleGlyph(size: kIsWeb ? _webIconSize : 20),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Continuar com o Google',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: kIsWeb ? _webFontSize : 15,
                    fontWeight: FontWeight.w600,
                    color: _socialButtonForeground,
                  ),
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
            padding: kIsWeb ? const EdgeInsets.symmetric(horizontal: 8) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_pillRadiusValue),
            ),
          ),
          child: const Text(
            'Continuar com um e-mail',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: kIsWeb ? _webFontSize : 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      },
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(AppAssets.iconGoogle, width: size, height: size);
  }
}
