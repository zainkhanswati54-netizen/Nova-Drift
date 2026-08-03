import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';
import '../core/debug_log.dart';
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

class _GameplayScreenState extends State<GameplayScreen>
    with WidgetsBindingObserver {
  // `key` on the game forces Flutter to throw away the old GameWidget
  // element and mount a brand-new one on retry(), which is what
  // actually gets Flame to re-run its attach/onLoad sequence from
  // scratch. Just swapping `_game` isn't enough on its own.
  Key _gameKey = UniqueKey();
  late NovaDriftGame _game = NovaDriftGame(mode: widget.mode);

  Timer? _watchdog;
  bool _showRecovery = false;
  bool _firstFrameLogged = false;
  bool _loadingBuilderLogged = false;

  /// Read directly from the platform layer (the raw window/view the
  /// Flutter engine is drawing into) instead of MediaQuery or
  /// LayoutBuilder. Both of those go through the widget/element/render
  /// tree, and on this device that whole chain was reporting a
  /// permanent (0,0) for this screen no matter how it was queried -
  /// even with GameWidget mounted directly, with no wrapper at all.
  /// PlatformDispatcher.views bypasses that tree completely and reads
  /// the window size the engine itself is using, so it can't be
  /// affected by whatever was breaking the widget-tree-based lookups.
  Size? _platformSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DebugLog.instance.add('GameplayScreen.initState (mode=${widget.mode}).');
    DebugLog.instance.add(
      'GameplayScreen: initial lifecycle state = '
      '${WidgetsBinding.instance.lifecycleState}.',
    );
    _readPlatformSize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_firstFrameLogged) {
        _firstFrameLogged = true;
        DebugLog.instance.add('GameplayScreen: first frame rendered.');
      }
    });
    _armWatchdog();
    _pumpFrames();
  }

  /// Belt-and-suspenders: repeatedly asks the engine to schedule a
  /// frame for a few seconds after this screen appears. Costs nothing
  /// if frames are already flowing normally. If the scheduler was ever
  /// stuck (not producing frames at all, which is what stalls Flame's
  /// entire Ticker-driven game loop - onLoad included), this gives it
  /// repeated nudges to start again instead of waiting on a single
  /// nudge that might get missed.
  void _pumpFrames() {
    for (var i = 1; i <= 25; i++) {
      Timer(Duration(milliseconds: 200 * i), () {
        if (!mounted) return;
        WidgetsBinding.instance.scheduleFrame();
      });
    }
  }

  void _readPlatformSize() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) {
      DebugLog.instance
          .add('WARNING: PlatformDispatcher.views is empty.');
      return;
    }
    final view = views.first;
    final physical = view.physicalSize;
    final ratio = view.devicePixelRatio;
    if (physical.width <= 0 || physical.height <= 0 || ratio <= 0) {
      DebugLog.instance.add(
        'WARNING: platform view size unusable '
        '(physical=$physical, devicePixelRatio=$ratio).',
      );
      return;
    }
    final logical = Size(physical.width / ratio, physical.height / ratio);
    if (logical != _platformSize) {
      DebugLog.instance.add(
        'GameplayScreen: platform size = ${logical.width}x${logical.height} '
        '(was $_platformSize).',
      );
      if (mounted) {
        setState(() => _platformSize = logical);
      } else {
        _platformSize = logical;
      }
    }
  }

  // Fires on rotation, keyboard, system UI changes, etc. - keeps
  // _platformSize current if it ever legitimately changes after the
  // initial read.
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _readPlatformSize();
  }

  // If Flutter ever thinks this screen isn't "resumed" (e.g. a stuck
  // system-UI/orientation transition on some devices), the scheduler
  // stops producing animation frames - which is also what drives
  // Flame's whole game loop (onLoad/onGameResize/update all ride on
  // it). This log is the only way to actually confirm that's what's
  // happening versus guessing from silence.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    DebugLog.instance.add('GameplayScreen: app lifecycle state = $state.');
    // Nudge the engine to keep producing frames regardless of what it
    // currently thinks its lifecycle state is - cheap and harmless if
    // frames were already flowing, but potentially unsticks Flame's
    // Ticker-driven game loop if they weren't.
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Root cause of the "stuck on the loading spinner forever" bug:
  /// if Flame's GameWidget ever gets attached while its parent reports
  /// a zero/degenerate size (e.g. mid page-transition, or while the
  /// forced landscape orientation is still settling right after
  /// launch), some Flame versions never retry - the loadingBuilder
  /// just stays up indefinitely even though nothing is actually wrong
  /// with the game code. Sizing GameWidget from [_platformSize] instead
  /// of the widget tree means it always gets sane numbers even when
  /// MediaQuery/LayoutBuilder along the way are stuck reporting zero.
  ///
  /// The watchdog + manual recovery banner below is a second, belt-
  /// and-suspenders safety net: if `onLoad` somehow still doesn't
  /// finish in time (e.g. a genuine bug gets introduced later), the
  /// player is never left staring at a spinner with no way out.
  void _armWatchdog() {
    _watchdog?.cancel();
    _showRecovery = false;
    _watchdog = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (!_game.isLoaded) {
        DebugLog.instance.add(
          'WARNING: watchdog fired - onLoad still not done 5s after '
          'GameplayScreen appeared. Showing manual recovery banner.',
        );
        setState(() => _showRecovery = true);
      }
    });
  }

  void _retry() {
    DebugLog.instance.add('GameplayScreen: manual retry requested.');
    setState(() {
      _game = NovaDriftGame(mode: widget.mode);
      _gameKey = UniqueKey();
    });
    _readPlatformSize();
    _armWatchdog();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _watchdog?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13315C),
      body: Stack(
        children: [
          Positioned.fill(
            child: Builder(
              builder: (context) {
                final size = _platformSize;
                if (size == null) {
                  DebugLog.instance.add(
                    'GameplayScreen: waiting for platform size before '
                    'mounting the game.',
                  );
                  return const ColoredBox(
                    color: Color(0xFF13315C),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    ),
                  );
                }
                DebugLog.instance.add(
                  'GameplayScreen: constructing GameWidget widget instance '
                  '(size ${size.width}x${size.height}).',
                );
                return Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: GameWidget(
                      key: _gameKey,
                      game: _game,
                      // DIAGNOSTIC: deliberately NOT the same colour as the
                      // Scaffold behind it. If the screen you actually see
                      // is plain navy blue with none of this magenta, that
                      // proves GameWidget's own Flutter-side widget is
                      // never even building - the bug is above/outside
                      // GameWidget entirely, not inside Flame's loading
                      // pipeline. If you DO see magenta, GameWidget is
                      // building fine and the bug is purely inside Flame's
                      // Game.onLoad() pipeline.
                      loadingBuilder: (context) {
                        if (!_loadingBuilderLogged) {
                          _loadingBuilderLogged = true;
                          DebugLog.instance.add(
                            'GameplayScreen: GameWidget.loadingBuilder '
                            'actually built (Flutter side is fine; the '
                            'bug is inside Flame\'s own load pipeline).',
                          );
                        }
                        return const ColoredBox(
                          color: Color(0xFFCC00CC),
                          child: Center(
                            child: Text(
                              'FLAME LOADING…',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
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
                );
              },
            ),
          ),
          // Manual recovery banner: only ever appears if the watchdog
          // above genuinely fires. Lets the player retry or bail out
          // instead of being stuck on a spinner forever.
          if (_showRecovery)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C0808),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Taking longer than expected to load…',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
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
                              fillTextColor: Colors.white,
                              onPressed: _retry,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
