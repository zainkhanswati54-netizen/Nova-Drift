import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised typography. The game uses one bold rounded family
/// everywhere, always uppercase, matching the reference screenshots.
class AppText {
  AppText._();

  static TextStyle title({Color color = Colors.white}) => GoogleFonts.rubik(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: color,
      );

  static TextStyle cardTitle(Color color) => GoogleFonts.rubik(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: color,
      );

  static TextStyle body(Color color) => GoogleFonts.rubik(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: color,
      );

  static TextStyle button(Color color) => GoogleFonts.rubik(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: color,
      );

  static TextStyle big(Color color) => GoogleFonts.rubik(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle small(Color color) => GoogleFonts.rubik(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
