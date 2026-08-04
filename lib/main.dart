import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/debug_log.dart';
import 'core/game_state.dart';
import 'screens/mode_select_screen.dart';
import 'widgets/debug_overlay.dart';

/// Replaces Flutter's default error box with something that's actually
/// visible against the game's dark backgrounds, and also logs it to
/// [DebugLog] so it shows up in the on-screen debug console (tap the
/// 🐞 button in the corner) - no PC or adb needed to see it.
void _installVisibleErrorScreen() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    DebugLog.instance.add('ERROR (widget build): ${details.exceptionAsString()}');
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
              const SizedBox(height: 8),
              const Text(
                'Full details are also in the 🐞 debug log button.',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  };
}

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _installVisibleErrorScreen();
    DebugLog.instance.add('App starting…');

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      DebugLog.instance.add('ERROR (Flutter): ${details.exceptionAsString()}');
    };

    await GameState.instance.load();
    DebugLog.instance.add('GameState loaded (gems=${GameState.instance.gems}).');

    runApp(const NovaDriftApp());

    // Landscape-only, fullscreen. Done *after* runApp/the first frame
    // instead of blocking startup on it, so a slow platform-channel
    // response here can never delay the first screen appearing.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      DebugLog.instance.add('Orientation locked, immersive mode set.');
    });
  }, (error, stack) {
    DebugLog.instance.add('ERROR (uncaught): $error');
    debugPrint('Uncaught error: $error\n$stack');
  });
}

class NovaDriftApp extends StatefulWidget {
  const NovaDriftApp({super.key});

  @override
  State<NovaDriftApp> createState() => _NovaDriftAppState();
}

class _NovaDriftAppState extends State<NovaDriftApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  OverlayEntry? _debugOverlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDebugOverlay());
  }

  // Inserted into the Navigator's own Overlay - the same layer
  // SnackBars/tooltips use - instead of wrapping every screen's content
  // in an extra Stack. This guarantees the 🐞 log button can never
  // affect any screen's layout constraints, while still floating above
  // whatever screen is currently showing.
  void _showDebugOverlay() {
    if (_debugOverlayEntry != null) return;
    final overlayState = _navigatorKey.currentState?.overlay;
    if (overlayState == null) return;
    _debugOverlayEntry = OverlayEntry(
      builder: (context) => const DebugOverlay(),
    );
    overlayState.insert(_debugOverlayEntry!);
  }

  @override
  void dispose() {
    _debugOverlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Nova Drift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ModeSelectScreen(),
    );
  }
}
