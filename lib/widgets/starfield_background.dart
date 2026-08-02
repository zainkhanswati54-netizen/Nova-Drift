import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// The white star-dots scattered over the coloured background.
/// Stars twinkle AND drift diagonally (small stars slower/dimmer =
/// far away, big stars faster/brighter = close - simple parallax),
/// wrapping around the edges, matching the "Drift" in Nova Drift.
class StarfieldBackground extends StatefulWidget {
  const StarfieldBackground({super.key, this.starCount = 110});

  final int starCount;

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final List<_Star> _stars;
  double _elapsedSeconds = 0;

  // Overall drift direction (down-left), like flying through space.
  static const double _driftAngle = 2.35; // radians

  @override
  void initState() {
    super.initState();
    final random = Random(7);
    _stars = List.generate(widget.starCount, (_) {
      final depth = random.nextDouble(); // 0 = far, 1 = close
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1.0 + depth * 2.6,
        phase: random.nextDouble() * 2 * pi,
        depth: depth,
      );
    });
    _ticker = createTicker((elapsed) {
      setState(() => _elapsedSeconds = elapsed.inMilliseconds / 1000.0);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _StarPainter(_stars, _elapsedSeconds),
      ),
    );
  }
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.depth,
  });

  final double x;
  final double y;
  final double size;
  final double phase;

  /// 0 = far (small, slow, dim) -> 1 = close (big, fast, bright).
  final double depth;
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.stars, this.t);

  final List<_Star> stars;
  final double t;

  static final double _dx = cos(_StarfieldBackgroundState._driftAngle);
  static final double _dy = sin(_StarfieldBackgroundState._driftAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      // Speed scales with depth (closer stars drift faster - parallax).
      final speed = 0.015 + star.depth * 0.05; // screens-per-second
      double px = star.x + _dx * speed * t;
      double py = star.y + _dy * speed * t;
      px -= px.floorToDouble();
      py -= py.floorToDouble();

      final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * sin(2 * pi * 0.4 * t + star.phase));
      final alpha = (0.25 + 0.55 * star.depth) * twinkle;
      final offset = Offset(px * size.width, py * size.height);

      // Small motion streak on the closer/faster stars for a sense of drift.
      if (star.depth > 0.45) {
        final double streakLen = 6.0 + star.depth * 16;
        paint
          ..color = Colors.white.withValues(alpha: alpha * 0.35)
          ..strokeWidth = star.size * 0.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          offset,
          offset - Offset(_dx * streakLen, _dy * streakLen),
          paint,
        );
      }

      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(offset, star.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => oldDelegate.t != t;
}
