import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/debug_log.dart';

/// A completely bare, empty Flame game - no components, no images, no
/// custom logic of any kind. Its only job is to prove (or disprove)
/// whether the "onLoad never fires" freeze is caused by something in
/// NovaDriftGame, or by Flame/this device/this Flutter version itself.
///
/// If THIS also freezes exactly the same way (onLoad never logs, watchdog
/// fires), the bug has nothing to do with our game code - it's Flame or
/// the device. If this loads fine, the bug is somewhere specific to
/// NovaDriftGame after all.
class _BareTestGame extends FlameGame {
  _BareTestGame() {
    pauseWhenBackgrounded = false;
  }

  @override
  Future<void> onLoad() async {
    DebugLog.instance.add(
      'BARE TEST: _BareTestGame.onLoad() called - Flame IS able to '
      'load a game on this device/build.',
    );
  }
}

class FlameDiagnosticScreen extends StatefulWidget {
  const FlameDiagnosticScreen({super.key});

  @override
  State<FlameDiagnosticScreen> createState() => _FlameDiagnosticScreenState();
}

class _FlameDiagnosticScreenState extends State<FlameDiagnosticScreen> {
  final _game = _BareTestGame();
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    DebugLog.instance.add('BARE TEST: diagnostic screen opened.');
    _watchdog = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (!_game.isLoaded) {
        DebugLog.instance.add(
          'BARE TEST: WARNING - even the bare empty FlameGame never '
          'finished loading after 5s. This confirms the freeze is NOT '
          'caused by anything in NovaDriftGame - it is Flame or this '
          'device/build itself.',
        );
      } else {
        DebugLog.instance.add(
          'BARE TEST: bare FlameGame loaded fine within 5s - the freeze '
          'is specific to NovaDriftGame, not Flame/device in general.',
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
      appBar: AppBar(title: const Text('Bare Flame Test')),
      body: GameWidget(
        game: _game,
        loadingBuilder: (context) => const ColoredBox(
          color: Color(0xFFCC00CC),
          child: Center(
            child: Text(
              'BARE FLAME LOADING…',
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
            child: Text(
              'Bare game failed to load:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
