import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';
import '../core/game_state.dart';
import '../widgets/coming_soon_dialog.dart';
import '../widgets/game_button.dart';
import '../widgets/gem_counter.dart';
import '../widgets/starfield_background.dart';
import 'gameplay_screen.dart';

/// "CLASSIC" world / level select - green theme like the reference screenshot.
/// Only WORLD 1 is playable; everything else is locked / Coming Soon.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  static const _palette = GamePalettes.green;

  @override
  Widget build(BuildContext context) {
    final state = GameState.instance;

    return Scaffold(
      backgroundColor: _palette.background,
      body: Stack(
        children: [
          const Positioned.fill(child: StarfieldBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Top bar: back, shop, title, gems
                  Row(
                    children: [
                      GameButton(
                        width: 56,
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      GameButton(
                        width: 56,
                        icon: Icons.shopping_cart_outlined,
                        onPressed: () => showComingSoon(context, 'Shop'),
                      ),
                      Expanded(
                        child: Center(
                          child: Text('CLASSIC', style: AppText.title()),
                        ),
                      ),
                      const GemCounter(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // World cards
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _WorldCard(
                          title: 'SPECIAL',
                          description: 'new worlds!!!',
                          progress: state.specialProgress,
                          dark: true,
                          onSelect: () =>
                              showComingSoon(context, 'Special Worlds'),
                        ),
                        const SizedBox(width: 14),
                        _WorldCard(
                          title: 'WORLD 1',
                          description: 'simple world with\nsimple levels',
                          progress: state.world1Progress,
                          onSelect: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GameplayScreen(
                                mode: 'Classic - World 1',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        _WorldCard(
                          title: 'WORLD 2',
                          description: 'EASY levels',
                          locked: true,
                          onSelect: () => showComingSoon(context, 'World 2'),
                        ),
                        const SizedBox(width: 14),
                        _WorldCard(
                          title: 'WORLD 3',
                          description: 'the floor is LAVA!',
                          locked: true,
                          onSelect: () => showComingSoon(context, 'World 3'),
                        ),
                        const SizedBox(width: 14),
                        const _ComingSoonCard(),
                      ],
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

class _WorldCard extends StatelessWidget {
  const _WorldCard({
    required this.title,
    required this.description,
    required this.onSelect,
    this.progress,
    this.locked = false,
    this.dark = false,
  });

  final String title;
  final String description;
  final VoidCallback onSelect;

  /// Completion percent shown in the top bar (null when locked).
  final int? progress;
  final bool locked;

  /// SPECIAL card uses the dark variant.
  final bool dark;

  static const _palette = GamePalettes.green;

  @override
  Widget build(BuildContext context) {
    final Color cardColor =
        dark ? const Color(0xFF0E4A36) : _palette.card;
    final Color textColor = dark ? Colors.white : _palette.onCard;
    final Color barColor = dark
        ? Colors.white.withValues(alpha: 0.25)
        : _palette.onCard.withValues(alpha: 0.25);

    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(title, style: AppText.cardTitle(textColor)),
          const SizedBox(height: 12),
          // Progress bar OR lock badge
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: locked
                  ? Icon(Icons.lock, size: 18, color: textColor)
                  : Text('${progress ?? 0}%', style: AppText.body(textColor)),
            ),
          ),
          const Spacer(),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppText.body(textColor),
          ),
          const Spacer(),
          GameButton(
            label: 'SELECT',
            color: textColor,
            width: double.infinity,
            enabled: !locked,
            onPressed: onSelect,
          ),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  static const _palette = GamePalettes.green;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: _palette.card,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'COMING\nSOON!',
          textAlign: TextAlign.center,
          style: AppText.cardTitle(_palette.onCard),
        ),
      ),
    );
  }
}
