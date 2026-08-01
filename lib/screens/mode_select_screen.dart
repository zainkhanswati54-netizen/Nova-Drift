import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';
import '../widgets/coming_soon_dialog.dart';
import '../widgets/game_button.dart';
import '../widgets/gem_counter.dart';
import '../widgets/mode_card.dart';
import '../widgets/starfield_background.dart';
import 'gameplay_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

/// "SELECT A GAME MODE" - the main menu.
/// The background palette slowly cycles (blue -> red -> green -> orange),
/// just like the reference screenshots show different colour states.
class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cycle;
  int _raceDifficulty = 0;
  static const _difficulties = ['EASY', 'MEDIUM', 'HARD'];

  @override
  void initState() {
    super.initState();
    // Full palette cycle takes 80 seconds (20s per palette).
    _cycle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  GamePalette _paletteAt(double t) {
    final palettes = GamePalettes.cycle;
    final scaled = t * palettes.length;
    final index = scaled.floor() % palettes.length;
    final next = (index + 1) % palettes.length;
    return GamePalette.lerp(palettes[index], palettes[next], scaled - scaled.floor());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cycle,
      builder: (context, _) {
        final palette = _paletteAt(_cycle.value);
        return Scaffold(
          backgroundColor: palette.background,
          body: Stack(
            children: [
              const Positioned.fill(child: StarfieldBackground()),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _TopBar(palette: palette),
                      Expanded(
                        child: Row(
                          children: [
                            _LeftRail(palette: palette),
                            Expanded(child: _modeCards(palette)),
                            _RightRail(palette: palette),
                          ],
                        ),
                      ),
                      _BottomBar(palette: palette),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modeCards(GamePalette palette) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CLASSIC
            ModeCard(
              palette: palette,
              title: 'CLASSIC',
              description: 'reach the finish\nto complete levels',
              middle: Icon(Icons.gesture, size: 44, color: palette.onCard),
              actions: [
                GameButton(
                  label: 'SELECT LEVEL',
                  color: palette.onCard,
                  width: double.infinity,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LevelSelectScreen(),
                    ),
                  ),
                ),
                GameButton(
                  filled: true,
                  fillTextColor: palette.onCard,
                  width: double.infinity,
                  onPressed: () => _startGame('Classic - World 1'),
                  child: _startLabel(palette),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // ENDLESS
            ModeCard(
              palette: palette,
              title: 'ENDLESS',
              description: 'go as far as possible\nand set a highscore',
              middle: Text('0m', style: AppText.big(palette.onCard)),
              actions: [
                GameButton(
                  filled: true,
                  fillTextColor: palette.onCard,
                  width: double.infinity,
                  onPressed: () => _startGame('Endless'),
                  child: _startLabel(palette),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // RACE
            ModeCard(
              palette: palette,
              title: 'RACE',
              description: 'reach the finish\nbefore others',
              middle: Icon(Icons.flag, size: 44, color: palette.onCard),
              actions: [
                GameButton(
                  color: palette.onCard,
                  width: double.infinity,
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _raceDifficulty =
                            (_raceDifficulty - 1 + _difficulties.length) %
                                _difficulties.length),
                        child: Icon(Icons.arrow_left,
                            color: palette.onCard, size: 26),
                      ),
                      Text(_difficulties[_raceDifficulty],
                          style: AppText.button(palette.onCard)),
                      GestureDetector(
                        onTap: () => setState(() => _raceDifficulty =
                            (_raceDifficulty + 1) % _difficulties.length),
                        child: Icon(Icons.arrow_right,
                            color: palette.onCard, size: 26),
                      ),
                    ],
                  ),
                ),
                GameButton(
                  filled: true,
                  fillTextColor: palette.onCard,
                  width: double.infinity,
                  onPressed: () =>
                      _startGame('Race - ${_difficulties[_raceDifficulty]}'),
                  child: _startLabel(palette),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _startLabel(GamePalette palette) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('START', style: AppText.button(palette.onCard)),
        Icon(Icons.play_arrow, size: 18, color: palette.onCard),
      ],
    );
  }

  void _startGame(String mode) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameplayScreen(mode: mode)),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.palette});

  final GamePalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 120),
        Expanded(
          child: Center(
            child: Text('SELECT A GAME MODE', style: AppText.title()),
          ),
        ),
        const SizedBox(width: 8),
        const GemCounter(),
      ],
    );
  }
}

class _LeftRail extends StatelessWidget {
  const _LeftRail({required this.palette});

  final GamePalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GameButton(
            width: 84,
            height: 72,
            onPressed: () => showComingSoon(context, 'Shop'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Text('SHOP', style: AppText.small(Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GameButton(
            width: 84,
            height: 72,
            onPressed: () => showComingSoon(context, 'Special Offer'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.percent, color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Text('OFFER', style: AppText.small(Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RightRail extends StatelessWidget {
  const _RightRail({required this.palette});

  final GamePalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GameButton(
            width: 84,
            height: 72,
            onPressed: () => showComingSoon(context, 'Daily Gift'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.card_giftcard, color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Text('GIFT', style: AppText.small(Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GameButton(
            width: 84,
            height: 72,
            onPressed: () => showComingSoon(context, 'Remove Ads'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Text('NO-ADS', style: AppText.small(Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.palette});

  final GamePalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GameButton(
          width: 150,
          icon: Icons.navigation,
          label: 'SKIN',
          onPressed: () => showComingSoon(context, 'Skins'),
        ),
        const SizedBox(width: 12),
        GameButton(
          width: 150,
          icon: Icons.settings,
          label: 'SETTINGS',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }
}
