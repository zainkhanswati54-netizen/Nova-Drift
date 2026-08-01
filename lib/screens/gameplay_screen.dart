import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';
import '../game/nova_drift_game.dart';
import '../widgets/game_button.dart';

/// Hosts the Flame [NovaDriftGame]: back button + live percent HUD
/// outside the canvas, plus intro / dead / complete overlays that are
/// driven by the game's own overlay state.
class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key, required this.mode});

  final String mode;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final NovaDriftGame _game = NovaDriftGame(mode: widget.mode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13315C),
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(
              game: _game,
              overlayBuilderMap: {
                'intro': (context, game) =>
                    _IntroOverlay(game: game as NovaDriftGame),
                'dead': (context, game) =>
                    _DeadOverlay(game: game as NovaDriftGame),
                'complete': (context, game) =>
                    _CompleteOverlay(game: game as NovaDriftGame),
              },
              initialActiveOverlays: const ['intro'],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GameButton(
                    width: 56,
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  ValueListenableBuilder<int>(
                    valueListenable: _game.percent,
                    builder: (context, value, _) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child:
                          Text('$value%', style: AppText.button(Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroOverlay extends StatelessWidget {
  const _IntroOverlay({required this.game});

  final NovaDriftGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GamePalettes.green.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WORLD 1 - LEVEL 1',
                style: AppText.cardTitle(GamePalettes.green.onCard),
              ),
              const SizedBox(height: 10),
              Text(
                'TAP AND HOLD TO FLY UP\nRELEASE TO FALL\nAVOID SPIKES & WALLS',
                textAlign: TextAlign.center,
                style: AppText.body(GamePalettes.green.onCard),
              ),
              const SizedBox(height: 16),
              GameButton(
                label: 'PLAY',
                filled: true,
                fillTextColor: GamePalettes.green.onCard,
                width: double.infinity,
                onPressed: game.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadOverlay extends StatelessWidget {
  const _DeadOverlay({required this.game});

  final NovaDriftGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GamePalettes.red.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CRASHED', style: AppText.cardTitle(Colors.white)),
              const SizedBox(height: 4),
              ValueListenableBuilder<int>(
                valueListenable: game.percent,
                builder: (context, value, _) => Text(
                  'you reached $value%',
                  style: AppText.body(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GameButton(
                      label: 'EXIT',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GameButton(
                      label: 'RETRY',
                      filled: true,
                      fillTextColor: GamePalettes.red.onCard,
                      onPressed: game.restart,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteOverlay extends StatelessWidget {
  const _CompleteOverlay({required this.game});

  final NovaDriftGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GamePalettes.green.card,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LEVEL COMPLETE!',
                style: AppText.cardTitle(GamePalettes.green.onCard),
              ),
              const SizedBox(height: 6),
              Text('+15 gems', style: AppText.body(GamePalettes.green.onCard)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GameButton(
                      label: 'RETRY',
                      color: GamePalettes.green.onCard,
                      onPressed: game.restart,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GameButton(
                      label: 'EXIT',
                      filled: true,
                      fillTextColor: GamePalettes.green.onCard,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
