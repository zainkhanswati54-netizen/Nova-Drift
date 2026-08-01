import 'package:flutter/material.dart';

/// A single colour palette for the game UI.
/// The real game slowly cycles its palette; [lerp] enables that.
class GamePalette {
  const GamePalette({
    required this.background,
    required this.card,
    required this.onCard,
    required this.buttonFill,
    required this.onButtonFill,
  });

  /// Full-screen background colour (with the starfield on top).
  final Color background;

  /// Mode / world card background.
  final Color card;

  /// Text + borders drawn on top of a card.
  final Color onCard;

  /// Filled buttons (START etc.) - white in the reference design.
  final Color buttonFill;

  /// Text on the filled buttons.
  final Color onButtonFill;

  static GamePalette lerp(GamePalette a, GamePalette b, double t) {
    return GamePalette(
      background: Color.lerp(a.background, b.background, t)!,
      card: Color.lerp(a.card, b.card, t)!,
      onCard: Color.lerp(a.onCard, b.onCard, t)!,
      buttonFill: Color.lerp(a.buttonFill, b.buttonFill, t)!,
      onButtonFill: Color.lerp(a.onButtonFill, b.onButtonFill, t)!,
    );
  }
}

/// Palettes matched to the reference screenshots, deepened for a
/// richer "space" feel (the original pastel tones read as washed out).
class GamePalettes {
  GamePalettes._();

  /// Blue theme (first screenshot).
  static const blue = GamePalette(
    background: Color(0xFF0F2C5C),
    card: Color(0xFF3E7FD1),
    onCard: Color(0xFF071A38),
    buttonFill: Color(0xFFFFFFFF),
    onButtonFill: Color(0xFF071A38),
  );

  /// Red theme (last screenshot).
  static const red = GamePalette(
    background: Color(0xFF6E1414),
    card: Color(0xFFD64B4B),
    onCard: Color(0xFF3C0808),
    buttonFill: Color(0xFFFFFFFF),
    onButtonFill: Color(0xFF3C0808),
  );

  /// Green theme (level-select screenshot).
  static const green = GamePalette(
    background: Color(0xFF0B5C40),
    card: Color(0xFF3BC98F),
    onCard: Color(0xFF052E20),
    buttonFill: Color(0xFFFFFFFF),
    onButtonFill: Color(0xFF052E20),
  );

  /// Extra palette so the slow cycle feels alive.
  static const orange = GamePalette(
    background: Color(0xFF7A3A0F),
    card: Color(0xFFE0863E),
    onCard: Color(0xFF3E1D08),
    buttonFill: Color(0xFFFFFFFF),
    onButtonFill: Color(0xFF3E1D08),
  );

  /// Cycle order used by the mode-select screen.
  static const cycle = <GamePalette>[blue, red, green, orange];
}
