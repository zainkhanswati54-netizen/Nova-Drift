import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/game_state.dart';
import 'screens/mode_select_screen.dart';

Future<void> main() async {
  // Wrapped so any error that would otherwise be swallowed silently in a
  // release build (leaving the player on a blank screen with no clue why)
  // gets printed to the device log instead.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

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
