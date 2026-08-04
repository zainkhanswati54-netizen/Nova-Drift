import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/debug_log.dart';
import '../game/nova_drift_game.dart';

/// The real [NovaDriftGame] - actual Level 1 logic, not a stand-in -
/// hosted with zero extra chrome: no watchdog, no HUD, no recovery
/// banner, no overlay map. Just `Scaffold > GameWidget > NovaDriftGame`,
/// as bare as [FlameDiagnosticScreen] but with the real game instead of
/// an empty one.
///
/// This isolates the one remaining variable: does the *real* game load
/// fine once every bit of surrounding screen complexity is stripped
/// away? If yes, whatever is still freezing GameplayScreen is something
/// in GameplayScreen's own wrapper, not NovaDriftGame. If this ALSO
/// freezes, the bug is genuinely inside NovaDriftGame.onLoad() itself,
/// or in something upstream of both screens (MaterialApp/root).
class MinimalGameplayScreen extends StatefulWidget {
  const MinimalGameplayScreen({super.key, required this.mode});

  final String mode;

  @override
  State<MinimalGameplayScreen> createState() => _MinimalGameplayScreenState();
}

class _MinimalGameplayScreenState extends State<MinimalGameplayScreen> {
  late final NovaDriftGame _game = NovaDriftGame(mode: widget.mode);
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    DebugLog.instance.add('MINIMAL TEST: screen opened (mode=${widget.mode}).');
    _watchdog = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (!_game.isLoaded) {
        DebugLog.instance.add(
          'MINIMAL TEST: WARNING - real NovaDriftGame did not finish '
          'loading within 5s even with zero extra screen chrome. The '
          'freeze is inside NovaDriftGame.onLoad() itself, or upstream '
          'of every screen (MaterialApp/root), not in GameplayScreen\'s '
          'own wrapper.',
        );
      } else {
        DebugLog.instance.add(
          'MINIMAL TEST: real NovaDriftGame loaded fine within 5s here. '
          'If GameplayScreen still freezes, the difference is something '
          'specific to GameplayScreen\'s own wrapper (HUD/overlays/'
          'watchdog), not NovaDriftGame or the app root.',
        );
      }
    });
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minimal Test: ${widget.mode}')),
      body: GameWidget(
        game: _game,
        loadingBuilder: (context) => const ColoredBox(
          color: Color(0xFFCC00CC),
          child: Center(
            child: Text(
              'REAL GAME LOADING…',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        errorBuilder: (context, error) => ColoredBox(
          color: const Color(0xFF3C0808),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Real game failed to load:\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
