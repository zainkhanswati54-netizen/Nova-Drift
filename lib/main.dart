import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/game_state.dart';
import 'screens/mode_select_screen.dart';

/// Replaces Flutter's default error box with something that's actually
/// visible against the game's dark backgrounds. Without this, a widget
/// that throws during build can render as a near-invisible grey box in
/// release mode, which is exactly what a "blank blue screen" bug report
/// usually turns out to be - something *did* fail, it just wasn't
/// shown. Now it always is, with the real error message on screen.
void _installVisibleErrorScreen() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('Widget build error: ${details.exceptionAsString()}');
    return Material(
      color: const Color(0xFF3C0808),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚠ Something broke while drawing this screen',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  };
}

Future<void> main() async {
  // Wrapped so any error that would otherwise be swallowed silently in a
  // release build (leaving the player on a blank screen with no clue why)
  // gets printed to the device log instead.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _installVisibleErrorScreen();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    // Landscape-only, fullscreen - like the reference game.
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await GameState.instance.load();

    runApp(const NovaDriftApp());
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

class NovaDriftApp extends StatelessWidget {
  const NovaDriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova Drift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ModeSelectScreen(),
    );
  }
}
