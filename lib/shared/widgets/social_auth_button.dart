import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/core/constants/auth_web_action_metrics.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

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

  static const _webSocialLabelStyle = TextStyle(
    fontSize: _webFontSize,
    fontWeight: FontWeight.w600,
    color: _socialButtonForeground,
  );
  static const _mobileSocialLabelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: _socialButtonForeground,
  );
  static const _webEmailLabelStyle = TextStyle(
    fontSize: _webFontSize,
    fontWeight: FontWeight.w700,
  );
  static const _mobileEmailLabelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  double get _buttonHeight =>
      kIsWeb ? AuthWebActionMetrics.buttonHeight : _height;

  double get _pillRadiusValue => kIsWeb ? _webPillRadius : _pillRadius;

  double get _appleIconSize => kIsWeb ? _webIconSize : 40;
  double get _googleIconSize => kIsWeb ? _webIconSize : 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: switch (provider) {
        SocialAuthProvider.apple => OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.apple,
            size: _appleIconSize,
            color: _socialButtonForeground,
          ),
          label: Text(
            l10n.authContinueWithApple,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kIsWeb ? _webSocialLabelStyle : _mobileSocialLabelStyle,
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
        SocialAuthProvider.google => OutlinedButton.icon(
          onPressed: onPressed,
          icon: _GoogleGlyph(size: _googleIconSize),
          label: Text(
            l10n.authContinueWithGoogle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kIsWeb ? _webSocialLabelStyle : _mobileSocialLabelStyle,
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
          child: Text(
            l10n.authContinueWithEmail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kIsWeb ? _webEmailLabelStyle : _mobileEmailLabelStyle,
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
