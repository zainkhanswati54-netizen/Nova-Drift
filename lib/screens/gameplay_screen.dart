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
              // Previously a failure anywhere during load (or a widget
              // exception while the game had no size yet) just left the
              // player staring at the plain navy backgroundColor() with
              // nothing on it - the "blue screen" bug. These two
              // builders make sure there's always something on screen:
              // a spinner while it's genuinely still loading, and the
              // real error message (instead of nothing) if it fails.
              loadingBuilder: (context) => const ColoredBox(
                color: Color(0xFF13315C),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                ),
              ),
              errorBuilder: (context, error) => ColoredBox(
                color: const Color(0xFF3C0808),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'The game failed to load:\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
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
                      const SizedBox(width: 10),
                      _PowerUpHud(game: _game),
                      const Spacer(),
                      _ProgressChip(game: _game),
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

/// Small chips that appear next to the back button while a shield,
/// magnet or slow-mo power-up is active, so the player always knows
/// what's currently helping them.
class _PowerUpHud extends StatelessWidget {
  const _PowerUpHud({required this.game});

  final NovaDriftGame game;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: game.shieldActive,
          builder: (context, active, _) => _chip(
            active,
            Icons.shield,
            const Color(0xFF6FE3FF),
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: game.magnetTimer,
          builder: (context, seconds, _) => _chip(
            seconds > 0,
            Icons.attractions,
            const Color(0xFFFF6FD8),
            seconds: seconds,
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: game.slowmoTimer,
          builder: (context, seconds, _) => _chip(
            seconds > 0,
            Icons.hourglass_bottom,
            const Color(0xFFBB8CFF),
            seconds: seconds,
          ),
        ),
      ],
    );
  }

  Widget _chip(bool visible, IconData icon, Color color, {double? seconds}) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            if (seconds != null) ...[
              const SizedBox(width: 4),
              Text(
                seconds.ceil().toString(),
                style: AppText.small(Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The little top-right pill in the HUD: live distance for Endless
/// (there's no "100%" to reach), live level percent otherwise.
class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.game});

  final NovaDriftGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: game.gameMode == GameMode.endless
          ? ValueListenableBuilder<int>(
              valueListenable: game.metersNotifier,
              builder: (context, value, _) =>
                  Text('${value}m', style: AppText.button(Colors.white)),
            )
          : ValueListenableBuilder<int>(
              valueListenable: game.percent,
              builder: (context, value, _) =>
                  Text('$value%', style: AppText.button(Colors.white)),
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
                _titleFor(game),
                style: AppText.cardTitle(GamePalettes.green.onCard),
              ),
              const SizedBox(height: 10),
              Text(
                _instructionsFor(game),
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

  String _titleFor(NovaDriftGame game) {
    switch (game.gameMode) {
      case GameMode.endless:
        return 'ENDLESS DRIFT';
      case GameMode.race:
        return 'RACE - ${game.mode.split(' - ').last}';
      case GameMode.classic:
        return 'WORLD 1 - LEVEL 1';
    }
  }

  String _instructionsFor(NovaDriftGame game) {
    const base = 'TAP AND HOLD TO FLY UP\nRELEASE TO FALL';
    const powerUps = 'GRAB SHIELD / MAGNET / SLOW-MO ORBS';
    switch (game.gameMode) {
      case GameMode.endless:
        return '$base\nCOLLECT GEMS - GO AS FAR AS YOU CAN\n$powerUps';
      case GameMode.race:
        return '$base\nBEAT THE RIVAL SHIP TO THE FLAG\n$powerUps';
      case GameMode.classic:
        return '$base\nAVOID SPIKES & WALLS\n$powerUps';
    }
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
              if (game.gameMode == GameMode.endless) ...[
                ValueListenableBuilder<int>(
                  valueListenable: game.metersNotifier,
                  builder: (context, value, _) => Text(
                    'you drifted ${value}m',
                    style: AppText.body(Colors.white),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: game.newBest,
                  builder: (context, isNew, _) => isNew
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'NEW BEST!',
                            style: AppText.body(GamePalettes.green.card),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ] else
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
              ValueListenableBuilder<bool?>(
                valueListenable: game.raceWon,
                builder: (context, won, _) {
                  final isRace = game.gameMode == GameMode.race;
                  final title = isRace
                      ? (won == false
                          ? 'RIVAL WON THE RACE'
                          : 'YOU WON THE RACE!')
                      : 'LEVEL COMPLETE!';
                  return Text(title,
                      style: AppText.cardTitle(GamePalettes.green.onCard));
                },
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<bool?>(
                valueListenable: game.raceWon,
                builder: (context, won, _) {
                  final lostRace =
                      game.gameMode == GameMode.race && won == false;
                  return Text(
                    lostRace ? 'no reward - try again' : '+15 gems',
                    style: AppText.body(GamePalettes.green.onCard),
                  );
                },
              ),
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
