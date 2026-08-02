import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/debug_log.dart';
import 'core/game_state.dart';
import 'screens/mode_select_screen.dart';
import 'widgets/debug_overlay.dart';

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

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    DebugLog.instance.add('Orientation locked, immersive mode set.');

    await GameState.instance.load();
    DebugLog.instance.add('GameState loaded (gems=${GameState.instance.gems}).');

    runApp(const NovaDriftApp());
    DebugLog.instance.add('runApp called.');
  }, (error, stack) {
    DebugLog.instance.add('ERROR (uncaught): $error');
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
      builder: (context, child) => Stack(
        children: [
          if (child != null) child,
          const DebugOverlay(),
        ],
      ),
      home: const ModeSelectScreen(),
    );
  }
}