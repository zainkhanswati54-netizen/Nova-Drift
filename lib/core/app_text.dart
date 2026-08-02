import 'package:flutter/material.dart';

/// Centralised typography. The game uses one bold rounded family
/// everywhere, always uppercase, matching the reference screenshots.
///
/// This used to fetch "Rubik" from Google Fonts (either over the network,
/// or from a bundled .ttf asset). Both approaches turned out fragile:
/// no internet -> network errors; runtime fetching disabled -> "font not
/// found in application assets" errors, since the .ttf files were never
/// actually added to the project. Plain [TextStyle] with just a
/// [FontWeight] uses the platform's built-in font (San Francisco on iOS,
/// Roboto on Android), which already ships with every weight we need -
/// no assets, no network, no missing-font exceptions, ever.
class AppText {
  AppText._();

  static TextStyle title({Color color = Colors.white}) => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: color,
      );

  static TextStyle cardTitle(Color color) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: color,
      );

  static TextStyle body(Color color) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: color,
      );

  static TextStyle button(Color color) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: color,
      );

  static TextStyle big(Color color) => TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle small(Color color) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
