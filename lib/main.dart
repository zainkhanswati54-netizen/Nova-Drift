import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/game_state.dart';
import 'screens/mode_select_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Landscape-only, fullscreen - like the reference game.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await GameState.instance.load();

  runApp(const NovaDriftApp());
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
