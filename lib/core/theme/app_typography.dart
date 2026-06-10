import 'package:flutter/material.dart';
import 'package:pokedex_app/core/theme/app_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme = TextTheme(
    headlineLarge: AppFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: AppFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: AppFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
    bodyLarge: AppFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: AppFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: AppFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
  );
}
