import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/game_state.dart';

/// Level 1 "wave rider" gameplay - same core loop as Space Waves:
/// the ship auto-scrolls forward at constant speed, holding makes it
/// climb at 45 degrees, releasing makes it dive at 45 degrees. Floor
/// and ceiling are flat and safe to slide on; spikes and blocks kill
/// on touch. Reach the flag at the end of the level to win.
///
/// `intro` -> `tutorial` (safe practice, no obstacles) -> `playing`
/// -> `dead` / `complete`.
enum RunPhase { intro, tutorial, playing, dead, complete }

/// The three guided steps shown during the tutorial, matching the
/// reference game's "press several times" / "hold for" / "click
/// anywhere to continue" prompts.
enum TutorialStep { tapSeveralTimes, holdFor, clickToContinue, finished }

class NovaDriftGame extends FlameGame with TapCallbacks {
  NovaDriftGame({required this.mode});

  /// e.g. "Classic - World 1".
  final String mode;

  static const double levelLength = 3800;
  static const double scrollSpeed = 230; // world units / second
  static const double verticalSpeed = 230; // px / second (45 degree wave)
  static const Color accent = Color(0xFF3BC98F);

  // Zone colours the background lerps through as the level plays out -
  // pink "warm-up", purple "moderate zig-zag", blue "narrow corridor" -
  // matching the phases in the level design brief.
  static const Color _zonePink = Color(0xFF9A0F66);
  static const Color _zonePurple = Color(0xFF4B22C9);
  static const Color _zoneBlue = Color(0xFF1560C4);
  static const double _phase1End = 0.30;

  // Tutorial-only background colours, matching the reference screenshots.
  static const Color _tutorialPurple = Color(0xFF4B22C9);
  static const Color _tutorialBlue = Color(0xFF1560C4);

  static const int tutorialTapsNeeded = 4;
  static const double tutorialHoldSeconds = 0.9;

  final ValueNotifier<RunPhase> phaseNotifier = ValueNotifier(RunPhase.intro);
  RunPhase get phase => phaseNotifier.value;
  set phase(RunPhase value) => phaseNotifier.value = value;

  final ValueNotifier<TutorialStep> tutorialStep =
      ValueNotifier(TutorialStep.tapSeveralTimes);
  final ValueNotifier<int> tutorialCounter =
      ValueNotifier(tutorialTapsNeeded);
  double _tutorialHoldTimer = 0;

  /// 0-100, drives the HUD readout and the "you reached X%" message.
  final ValueNotifier<int> percent = ValueNotifier<int>(0);

  double distance = 0;
  bool holding = false;

  double shipScreenX = 140;
  double topY = 100;
  double bottomY = 500;

  final List<Offset> trail = [];
  late final List<_LevelObstacle> obstacles;
  late final _Ship ship;

  bool _ready = false;

  double get shipHitRadius => 9;

  /// Trail colour changes with the tutorial step so it visually matches
  /// the reference screenshots (white -> light blue -> pink), settling
  /// back to the game's accent colour for real gameplay.
  Color get trailColor {
    if (phase == RunPhase.tutorial) {
      switch (tutorialStep.value) {
        case TutorialStep.tapSeveralTimes:
          return Colors.white;
        case TutorialStep.holdFor:
          return const Color(0xFF8FD9FF);
        case TutorialStep.clickToContinue:
          return const Color(0xFFFF6FD8);
        case TutorialStep.finished:
          return accent;
      }
    }
    return accent;
  }

  @override
  Color backgroundColor() {
    switch (phase) {
      case RunPhase.intro:
        return const Color(0xFF13315C);
      case RunPhase.tutorial:
        return tutorialStep.value == TutorialStep.clickToContinue
            ? _tutorialBlue
            : _tutorialPurple;
      case RunPhase.playing:
      case RunPhase.dead:
      case RunPhase.complete:
        return _zoneColor(distance);
    }
  }

  /// Pink (warm-up) -> purple (moderate) -> blue (narrow corridor),
  /// lerped smoothly against how far through the level the ship is.
  Color _zoneColor(double d) {
    final t = (d / levelLength).clamp(0.0, 1.0);
    if (t <= _phase1End) {
      return Color.lerp(_zonePink, _zonePurple, t / _phase1End)!;
    }
    return Color.lerp(
      _zonePurple,
      _zoneBlue,
      (t - _phase1End) / (1 - _phase1End),
    )!;
  }

  @override
  Future<void> onLoad() async {
    obstacles = _buildLevel();
    ship = _Ship();

    add(_ScrollingStars());
    add(_Track());
    add(ship);

    overlays.add('intro');
    _ready = true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    shipScreenX = size.x * 0.26;
    topY = size.y * 0.16;
    bottomY = size.y * 0.90;
    if (_ready) {
      ship.position.x = shipScreenX;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (phase == RunPhase.tutorial) {
      _updateTutorial(dt);
      return;
    }
    if (phase != RunPhase.playing) return;

    distance += scrollSpeed * dt;
    trail.add(Offset(distance, ship.position.y));
    if (trail.length > 320) trail.removeAt(0);

    final pct = ((distance / levelLength) * 100).clamp(0, 100).round();
    if (pct != percent.value) percent.value = pct;

    final shipCenter = Offset(shipScreenX, ship.position.y);
    for (final o in obstacles) {
      final screenX = o.worldX - distance + shipScreenX;
      if (screenX < -100 || screenX > size.x + 100) continue;
      if (o.hits(shipCenter, shipHitRadius, screenX, topY, bottomY)) {
        _die();
        return;
      }
    }

    if (distance >= levelLength) {
      _completeLevel();
    }
  }

  /// Drives the practice loop: the trail/ship keep animating exactly
  /// like real gameplay (so the zig-zag / climb / glide draw
  /// themselves live) but there are no obstacles and nothing to lose.
  void _updateTutorial(double dt) {
    distance += scrollSpeed * dt;
    trail.add(Offset(distance, ship.position.y));
    if (trail.length > 320) trail.removeAt(0);

    if (tutorialStep.value == TutorialStep.holdFor) {
      if (holding) {
        _tutorialHoldTimer += dt;
        if (_tutorialHoldTimer >= tutorialHoldSeconds) {
          _advanceTutorialStep();
        }
      } else {
        _tutorialHoldTimer = 0;
      }
    }
  }

  void start() {
    if (phase != RunPhase.intro) return;
    phase = RunPhase.tutorial;
    tutorialStep.value = TutorialStep.tapSeveralTimes;
    tutorialCounter.value = tutorialTapsNeeded;
    _tutorialHoldTimer = 0;
    distance = 0;
    trail.clear();
    ship.reset();
    overlays.remove('intro');
    overlays.add('tutorial');
  }

  /// Lets the player jump straight into the real level.
  void skipTutorial() {
    if (phase != RunPhase.tutorial) return;
    _finishTutorial();
  }

  void _handleTutorialTap() {
    switch (tutorialStep.value) {
      case TutorialStep.tapSeveralTimes:
        tutorialCounter.value =
            (tutorialCounter.value - 1).clamp(0, tutorialTapsNeeded);
        if (tutorialCounter.value == 0) _advanceTutorialStep();
        break;
      case TutorialStep.clickToContinue:
        _advanceTutorialStep();
        break;
      case TutorialStep.holdFor:
      case TutorialStep.finished:
        break;
    }
  }

  void _advanceTutorialStep() {
    switch (tutorialStep.value) {
      case TutorialStep.tapSeveralTimes:
        tutorialStep.value = TutorialStep.holdFor;
        tutorialCounter.value = 1;
        _tutorialHoldTimer = 0;
        break;
      case TutorialStep.holdFor:
        tutorialStep.value = TutorialStep.clickToContinue;
        break;
      case TutorialStep.clickToContinue:
        _finishTutorial();
        break;
      case TutorialStep.finished:
        break;
    }
  }

  void _finishTutorial() {
    tutorialStep.value = TutorialStep.finished;
    overlays.remove('tutorial');
    distance = 0;
    trail.clear();
    holding = false;
    ship.reset();
    phase = RunPhase.playing;
  }

  void restart() {
    distance = 0;
    percent.value = 0;
    trail.clear();
    holding = false;
    ship.reset();
    overlays.remove('dead');
    overlays.remove('complete');
    phase = RunPhase.playing;
  }

  void _die() {
    phase = RunPhase.dead;
    holding = false;
    overlays.add('dead');
  }

  void _completeLevel() {
    phase = RunPhase.complete;
    holding = false;
    overlays.add('complete');
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    final state = GameState.instance;
    await state.setWorld1Progress(20);
    await state.addGems(15);
  }

  @override
  void onTapDown(TapDownEvent event) {
    holding = true;
    switch (phase) {
      case RunPhase.intro:
        start();
        break;
      case RunPhase.tutorial:
        _handleTutorialTap();
        break;
      case RunPhase.playing:
      case RunPhase.dead:
      case RunPhase.complete:
        break;
    }
  }

  @override
  void onTapUp(TapUpEvent event) => holding = false;

  @override
  void onTapCancel(TapCancelEvent event) => holding = false;

  @override
  void onRemove() {
    percent.dispose();
    phaseNotifier.dispose();
    tutorialStep.dispose();
    tutorialCounter.dispose();
    super.onRemove();
  }

  /// World 1 - Level 1, built in the same three phases described in
  /// the design brief:
  ///  - Warm-up (0-30%): wide open gaps, single spikes, long holds.
  ///  - Moderate zig-zag (30-70%): tighter spacing plus a few blocks
  ///    that need a real full climb or dive.
  ///  - Narrow corridor (70-100%): small, frequent spikes that call
  ///    for quick micro-taps, ending in a tight gate before the flag.
  List<_LevelObstacle> _buildLevel() {
    final obstacles = <_LevelObstacle>[];
    final rand = Random(7); // seeded so the layout is reproducible

    final phase1End = levelLength * 0.30;
    final phase2End = levelLength * 0.70;
    final phase3End = levelLength - 260;

    double x = 480;
    bool fromFloor = true;

    // Phase 1: warm-up - wide gaps, one spike at a time.
    while (x < phase1End) {
      obstacles.add(
        fromFloor
            ? _LevelObstacle.floorSpike(x)
            : _LevelObstacle.ceilingSpike(x),
      );
      fromFloor = !fromFloor;
      x += 320 + rand.nextInt(60);
    }

    // Phase 2: moderate zig-zag - closer spikes, occasional blocks
    // that force a full climb or dive rather than a quick tap.
    int i = 0;
    while (x < phase2End) {
      if (i % 3 == 2) {
        obstacles.add(
          fromFloor
              ? _LevelObstacle.floorBlock(x, sizeFraction: 0.42)
              : _LevelObstacle.ceilingBlock(x, sizeFraction: 0.42),
        );
      } else {
        obstacles.add(
          fromFloor
              ? _LevelObstacle.floorSpike(x)
              : _LevelObstacle.ceilingSpike(x),
        );
      }
      fromFloor = !fromFloor;
      x += 220 + rand.nextInt(50);
      i++;
    }

    // Phase 3: narrow corridor - small, frequent spikes, micro-tap
    // territory, right up to a tight gate before the finish flag.
    while (x < phase3End) {
      obstacles.add(
        fromFloor
            ? _LevelObstacle.floorSpike(x, width: 26, sizeFraction: 0.26)
            : _LevelObstacle.ceilingSpike(x, width: 26, sizeFraction: 0.26),
      );
      fromFloor = !fromFloor;
      x += 140 + rand.nextInt(30);
    }

    obstacles.add(
      _LevelObstacle.floorBlock(levelLength - 170,
          sizeFraction: 0.32, width: 40),
    );
    obstacles.add(
      _LevelObstacle.ceilingBlock(levelLength - 170,
          sizeFraction: 0.32, width: 40),
    );

    return obstacles;
  }
}

/// The player's arrow. Pinned to a fixed screen X; the level scrolls
/// underneath it. Holding = climb at 45 degrees, releasing = dive at
/// 45 degrees - identical feel to the reference game's tutorial. Also
/// active (unharmed) during the practice tutorial.
class _Ship extends PositionComponent with HasGameReference<NovaDriftGame> {
  _Ship() : super(size: Vector2.all(20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    reset();
  }

  void reset() {
    position = Vector2(
      game.shipScreenX,
      game.bottomY - game.shipHitRadius - 2,
    );
    angle = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x = game.shipScreenX;
    if (game.phase != RunPhase.playing && game.phase != RunPhase.tutorial) {
      return;
    }

    final dir = game.holding ? -1.0 : 1.0;
    position.y += dir * NovaDriftGame.verticalSpeed * dt;
    position.y = position.y
        .clamp(game.topY + game.shipHitRadius, game.bottomY - game.shipHitRadius)
        .toDouble();
    angle = dir < 0 ? -pi / 4 : pi / 4;
  }

  @override
  void render(Canvas canvas) {
    final fill = Paint()..color = Colors.white;
    final outline = Paint()
      ..color = const Color(0xFF052E20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(-9, -8)
      ..lineTo(12, 0)
      ..lineTo(-9, 8)
      ..close();
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);
    canvas.restore();
  }
}

/// Draws the flat floor/ceiling bounds, the ship's wave trail, every
/// obstacle currently on screen, and the finish flag. Everything here
/// is pure "camera space" - X positions are recomputed every frame
/// from `worldX - distance`, so nothing needs to move itself.
/// Obstacles and the flag are hidden during `intro`/`tutorial` so the
/// practice area is a clean, safe sandbox.
class _Track extends Component with HasGameReference<NovaDriftGame> {
  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final topY = game.topY;
    final bottomY = game.bottomY;

    final bandPaint = Paint()..color = Colors.black.withValues(alpha: 0.18);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, topY), bandPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, bottomY, w, game.size.y - bottomY),
      bandPaint,
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, topY), Offset(w, topY), linePaint);
    canvas.drawLine(Offset(0, bottomY), Offset(w, bottomY), linePaint);

    if (game.trail.length > 1) {
      final path = Path();
      var first = true;
      for (final p in game.trail) {
        final sx = p.dx - game.distance + game.shipScreenX;
        if (first) {
          path.moveTo(sx, p.dy);
          first = false;
        } else {
          path.lineTo(sx, p.dy);
        }
      }
      final glow = Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final core = Paint()
        ..color = game.trailColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, glow);
      canvas.drawPath(path, core);
    }

    final showLevel = game.phase == RunPhase.playing ||
        game.phase == RunPhase.dead ||
        game.phase == RunPhase.complete;
    if (!showLevel) return;

    for (final o in game.obstacles) {
      final screenX = o.worldX - game.distance + game.shipScreenX;
      if (screenX < -100 || screenX > w + 100) continue;
      o.draw(canvas, screenX, topY, bottomY);
    }

    final finishX =
        NovaDriftGame.levelLength - game.distance + game.shipScreenX;
    if (finishX > -60 && finishX < w + 60) {
      _drawFinish(canvas, finishX, topY, bottomY);
    }
  }

  void _drawFinish(Canvas canvas, double x, double top, double bottom) {
    final postPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5;
    var y = top;
    while (y < bottom) {
      final segEnd = min(y + 14, bottom);
      canvas.drawLine(Offset(x, y), Offset(x, segEnd), postPaint);
      y += 24;
    }
    final flagPaint = Paint()..color = NovaDriftGame.accent;
    final flag = Path()
      ..moveTo(x, top + 4)
      ..lineTo(x + 28, top + 16)
      ..lineTo(x, top + 28)
      ..close();
    canvas.drawPath(flag, flagPaint);
  }
}

/// One obstacle: a spike (triangle) or block (rectangle) anchored to
/// either the floor or the ceiling. Sizes are expressed as a fraction
/// of the playfield height so the level scales to any screen size.
class _LevelObstacle {
  const _LevelObstacle._({
    required this.worldX,
    required this.width,
    required this.fromFloor,
    required this.isSpike,
    required this.sizeFraction,
  });

  factory _LevelObstacle.floorSpike(
    double worldX, {
    double width = 34,
    double sizeFraction = 0.30,
  }) =>
      _LevelObstacle._(
        worldX: worldX,
        width: width,
        fromFloor: true,
        isSpike: true,
        sizeFraction: sizeFraction,
      );

  factory _LevelObstacle.ceilingSpike(
    double worldX, {
    double width = 34,
    double sizeFraction = 0.30,
  }) =>
      _LevelObstacle._(
        worldX: worldX,
        width: width,
        fromFloor: false,
        isSpike: true,
        sizeFraction: sizeFraction,
      );

  factory _LevelObstacle.floorBlock(
    double worldX, {
    double width = 46,
    double sizeFraction = 0.5,
  }) =>
      _LevelObstacle._(
        worldX: worldX,
        width: width,
        fromFloor: true,
        isSpike: false,
        sizeFraction: sizeFraction,
      );

  factory _LevelObstacle.ceilingBlock(
    double worldX, {
    double width = 46,
    double sizeFraction = 0.5,
  }) =>
      _LevelObstacle._(
        worldX: worldX,
        width: width,
        fromFloor: false,
        isSpike: false,
        sizeFraction: sizeFraction,
      );

  final double worldX;
  final double width;
  final bool fromFloor;
  final bool isSpike;
  final double sizeFraction;

  bool hits(
    Offset shipCenter,
    double radius,
    double screenX,
    double topY,
    double bottomY,
  ) {
    final playH = bottomY - topY;
    final h = playH * sizeFraction;
    final left = screenX - width / 2;
    final right = screenX + width / 2;

    if (isSpike) {
      final baseY = fromFloor ? bottomY : topY;
      final apexY = fromFloor ? bottomY - h : topY + h;
      final p1 = Offset(left, baseY);
      final p2 = Offset(right, baseY);
      final p3 = Offset(screenX, apexY);
      // Shrink the hitbox toward the centroid so grazing the edge of
      // the sprite isn't an instant, unfair death.
      final centroid = Offset(
        (p1.dx + p2.dx + p3.dx) / 3,
        (p1.dy + p2.dy + p3.dy) / 3,
      );
      Offset shrink(Offset p) => Offset.lerp(centroid, p, 0.78)!;
      return _circleHitsTriangle(
        shipCenter,
        radius,
        shrink(p1),
        shrink(p2),
        shrink(p3),
      );
    }

    final top = fromFloor ? bottomY - h : topY;
    final bottom = fromFloor ? bottomY : topY + h;
    final rect = Rect.fromLTRB(left + 3, top, right - 3, bottom);
    return _circleHitsRect(shipCenter, radius, rect);
  }

  void draw(Canvas canvas, double screenX, double topY, double bottomY) {
    final playH = bottomY - topY;
    final h = playH * sizeFraction;
    final left = screenX - width / 2;
    final right = screenX + width / 2;

    final fill = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = NovaDriftGame.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (isSpike) {
      final baseY = fromFloor ? bottomY : topY;
      final apexY = fromFloor ? bottomY - h : topY + h;
      final path = Path()
        ..moveTo(left, baseY)
        ..lineTo(right, baseY)
        ..lineTo(screenX, apexY)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    } else {
      final top = fromFloor ? bottomY - h : topY;
      final bottom = fromFloor ? bottomY : topY + h;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, stroke);
    }
  }
}

bool _circleHitsRect(Offset c, double r, Rect rect) {
  final nx = c.dx.clamp(rect.left, rect.right);
  final ny = c.dy.clamp(rect.top, rect.bottom);
  final dx = c.dx - nx;
  final dy = c.dy - ny;
  return dx * dx + dy * dy <= r * r;
}

bool _circleHitsTriangle(Offset c, double r, Offset a, Offset b, Offset cPt) {
  if (_pointInTriangle(c, a, b, cPt)) return true;
  return _distToSegment(c, a, b) <= r ||
      _distToSegment(c, b, cPt) <= r ||
      _distToSegment(c, cPt, a) <= r;
}

double _cross(Offset o, Offset a, Offset b) =>
    (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);

bool _pointInTriangle(Offset p, Offset a, Offset b, Offset c) {
  final d1 = _cross(p, a, b);
  final d2 = _cross(p, b, c);
  final d3 = _cross(p, c, a);
  final hasNeg = d1 < 0 || d2 < 0 || d3 < 0;
  final hasPos = d1 > 0 || d2 > 0 || d3 > 0;
  return !(hasNeg && hasPos);
}

double _distToSegment(Offset p, Offset a, Offset b) {
  final abx = b.dx - a.dx;
  final aby = b.dy - a.dy;
  final lenSq = abx * abx + aby * aby;
  double t = lenSq == 0
      ? 0
      : (((p.dx - a.dx) * abx) + ((p.dy - a.dy) * aby)) / lenSq;
  t = t.clamp(0.0, 1.0).toDouble();
  final projX = a.dx + abx * t;
  final projY = a.dy + aby * t;
  final dx = p.dx - projX;
  final dy = p.dy - projY;
  return sqrt(dx * dx + dy * dy);
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
