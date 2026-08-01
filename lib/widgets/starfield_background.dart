import 'dart:math';

import 'package:flutter/material.dart';

/// The subtle white star-dots scattered over the coloured background,
/// gently twinkling - matches the reference screenshots.
class StarfieldBackground extends StatefulWidget {
  const StarfieldBackground({super.key, this.starCount = 90});

  final int starCount;

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final random = Random(7);
    _stars = List.generate(widget.starCount, (_) {
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1.0 + random.nextDouble() * 2.2,
        phase: random.nextDouble() * 2 * pi,
      );
    });
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _StarPainter(_stars, _controller.value),
        ),
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
  });

  final double x;
  final double y;
  final double size;
  final double phase;
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.stars, this.t);

  final List<_Star> stars;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * sin(2 * pi * t + star.phase));
      paint.color = Colors.white.withValues(alpha: 0.55 * twinkle);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => oldDelegate.t != t;
}
