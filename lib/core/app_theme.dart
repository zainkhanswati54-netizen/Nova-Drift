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

/// Palettes matched to the reference screenshots.
class GamePalettes {
  GamePalettes._();

  /// Blue theme (first screenshot).
  static const blue = GamePalette(
    background: Color(0xFF2F6FC2),
    card: Color(0xFF9CC9F0),
    onCard: Color(0xFF1E4372),
    buttonFill: Color(0xFFFFFFFF),
    onButtonFill: Color(0xFF1E4372),
  );

  /// Red theme (last screenshot).
  static const red = GamePalette(
    background: Color(0xFFC22F2F),
    card: Color(0xFFF0A2A2),
    onCard: Color(0xFF6E1B1B),
    buttonFill: Color(0xFFFFFFFF),
    onButtonFill: Color(0xFF6E1B1B),
  );

  /// Green theme (level-select screenshot).
  static const green = GamePalette(
    background: Color(0xFF1C8A66),
    card: Color(0xFF8FEFC8),
    onCard: Color(0xFF0E4A36),
    buttonFill: Color(0xFFFFFFFF),
    onButtonFill: Color(0xFF0E4A36),
  );

  /// Extra palette so the slow cycle feels alive.
  static const orange = GamePalette(
    background: Color(0xFFC2702F),
    card: Color(0xFFF0C89C),
    onCard: Color(0xFF6E3E12),
    buttonFill: Color(0xFFFFFFFF),
    onButtonFill: Color(0xFF6E3E12),
  );

  /// Cycle order used by the mode-select screen.
  static const cycle = <GamePalette>[blue, red, green, orange];
}
