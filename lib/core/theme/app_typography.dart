import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
  );
}
