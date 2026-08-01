import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// The Flame game skeleton. The real wave-riding gameplay
/// (hold-to-fly-up arrow ship, spikes, finish line) plugs in here later.
///
/// Right now it renders a scrolling starfield + "GAMEPLAY COMING SOON",
/// proving the Flame pipeline is fully wired and ready.
class NovaDriftGame extends FlameGame {
  NovaDriftGame({required this.mode});

  /// e.g. "Classic - World 1", "Endless", "Race - EASY".
  final String mode;

  @override
  Color backgroundColor() => const Color(0xFF13315C);

  @override
  Future<void> onLoad() async {
    // Scrolling star layer - placeholder for the parallax background.
    add(_ScrollingStars());

    // Centered "coming soon" text - replace with the player + level.
    add(
      TextComponent(
        text: 'GAMEPLAY COMING SOON',
        anchor: Anchor.center,
        position: size / 2,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );

    add(
      TextComponent(
        text: mode.toUpperCase(),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2 + 40),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Simple right-to-left scrolling stars so the screen feels alive.
class _ScrollingStars extends Component with HasGameReference<NovaDriftGame> {
  final List<_Star> _stars = [];
  final Random _random = Random();

  @override
  void onMount() {
    super.onMount();
    for (int i = 0; i < 70; i++) {
      _stars.add(
        _Star(
          position: Vector2(
            _random.nextDouble() * game.size.x,
            _random.nextDouble() * game.size.y,
          ),
          radius: 0.5 + _random.nextDouble() * 1.6,
          speed: 20 + _random.nextDouble() * 60,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final star in _stars) {
      star.position.x -= star.speed * dt;
      if (star.position.x < -2) {
        star.position.x = game.size.x + 2;
        star.position.y = _random.nextDouble() * game.size.y;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    for (final star in _stars) {
      canvas.drawCircle(star.position.toOffset(), star.radius, paint);
    }
  }
}

class _Star {
  _Star({required this.position, required this.radius, required this.speed});

  final Vector2 position;
  final double radius;
  final double speed;
}
