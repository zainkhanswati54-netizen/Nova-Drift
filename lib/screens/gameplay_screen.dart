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
                'tutorial': (context, game) =>
                    _TutorialOverlay(game: game as NovaDriftGame),
                'dead': (context, game) =>
                    _DeadOverlay(game: game as NovaDriftGame),
                'complete': (context, game) =>
                    _CompleteOverlay(game: game as NovaDriftGame),
              },
              initialActiveOverlays: const ['intro'],
            ),
          ),
          // Back button + progress chip - hidden during intro/tutorial,
          // which have their own dedicated top bars.
          ValueListenableBuilder<RunPhase>(
            valueListenable: _game.phaseNotifier,
            builder: (context, phase, _) {
              final showHud =
                  phase == RunPhase.playing ||
                  phase == RunPhase.dead ||
                  phase == RunPhase.complete;
              if (!showHud) return const SizedBox.shrink();
              return SafeArea(
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
                            border:
                                Border.all(color: Colors.white24, width: 2),
                          ),
                          child: Text('$value%',
                              style: AppText.button(Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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

/// Interactive practice overlay shown before the real level starts.
/// The player taps a few times to draw a zig-zag, then holds once to
/// climb, then taps once more to jump into the real run - matching
/// the reference game's tutorial flow. A skip button is always
/// available for returning players.
class _TutorialOverlay extends StatelessWidget {
  const _TutorialOverlay({required this.game});

  final NovaDriftGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                    child: const Text('🇬🇧', style: TextStyle(fontSize: 16)),
                  ),
                  const Spacer(),
                  GameButton(
                    label: 'Skip tutorial',
                    onPressed: game.skipTutorial,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                'Tap and hold to fly up / slide on the ceiling',
                textAlign: TextAlign.center,
                style: AppText.body(Colors.white),
              ),
            ),
            const Spacer(),
            ValueListenableBuilder<TutorialStep>(
              valueListenable: game.tutorialStep,
              builder: (context, step, _) {
                if (step == TutorialStep.finished) {
                  return const SizedBox.shrink();
                }
                final showCounter = step == TutorialStep.tapSeveralTimes ||
                    step == TutorialStep.holdFor;
                return Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_promptFor(step), style: AppText.button(Colors.white)),
                      if (showCounter) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.play_arrow,
                            size: 14, color: Colors.white54),
                        ValueListenableBuilder<int>(
                          valueListenable: game.tutorialCounter,
                          builder: (context, count, _) => Text(
                            '$count',
                            style: AppText.button(Colors.white70),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _promptFor(TutorialStep step) {
    switch (step) {
      case TutorialStep.tapSeveralTimes:
        return 'press several times';
      case TutorialStep.holdFor:
        return 'hold for';
      case TutorialStep.clickToContinue:
        return 'click anywhere to continue';
      case TutorialStep.finished:
        return '';
    }
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
