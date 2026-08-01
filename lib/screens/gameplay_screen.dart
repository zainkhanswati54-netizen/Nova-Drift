import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/nova_drift_game.dart';
import '../widgets/game_button.dart';

/// Hosts the Flame [NovaDriftGame] with a back-button overlay.
class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key, required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(game: NovaDriftGame(mode: mode)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GameButton(
                width: 56,
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
