import 'package:flutter/material.dart';

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