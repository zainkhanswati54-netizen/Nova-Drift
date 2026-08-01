import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';
import '../core/game_state.dart';
import '../widgets/coming_soon_dialog.dart';
import '../widgets/game_button.dart';
import '../widgets/gem_counter.dart';
import '../widgets/mini_switch.dart';
import '../widgets/settings_option_button.dart';
import '../widgets/starfield_background.dart';

/// Dialogs everywhere in the game share this fixed dark navy, regardless
/// of the current cycling palette - keeps popups readable/consistent
/// (same colour coming_soon_dialog.dart uses).
const _kDialogColor = Color(0xFF13315C);

/// "SETTINGS" screen. Same slow colour-cycling background as the main
/// menu (blue -> red -> green -> orange) instead of a single fixed
/// theme, so it feels like part of the same game rather than a
/// different screen bolted on.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  // Same 80s full-cycle speed as ModeSelectScreen, so the palette stays
  // in sync with wherever it was when SETTINGS was opened.
  late final AnimationController _cycle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 80),
  )..repeat();

  Animation<double> _rowAnim(int index) {
    final double start = 0.12 * index;
    final double end = (start + 0.55).clamp(0.0, 1.0).toDouble();
    return CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _enter.dispose();
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

  Widget _staggered({required int index, required Widget child}) {
    final anim = _rowAnim(index);
    return AnimatedBuilder(
      animation: anim,
      builder: (context, c) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 24.0 * (1.0 - anim.value)),
            child: c,
          ),
        );
      },
      child: child,
    );
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
                      // Top bar: back, cart, title, gems
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
                              child: Text('SETTINGS', style: AppText.title()),
                            ),
                          ),
                          const GemCounter(),
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  _staggered(
                                    index: 0,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ListenableBuilder(
                                            listenable: GameState.instance,
                                            builder: (context, _) {
                                              final on = GameState.instance.soundOn;
                                              return SettingsOptionButton(
                                                leading: Icon(on
                                                    ? Icons.volume_up
                                                    : Icons.volume_off),
                                                label: 'Sound',
                                                active: true,
                                                trailing: MiniSwitch(
                                                    value: on, onColor: palette.onCard),
                                                onTap: () => GameState.instance
                                                    .setSoundOn(!on),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ListenableBuilder(
                                            listenable: GameState.instance,
                                            builder: (context, _) {
                                              return SettingsOptionButton(
                                                leading: const Icon(Icons.language),
                                                label: GameState.instance.language,
                                                active: true,
                                                trailing: const Icon(
                                                    Icons.expand_more,
                                                    color: Colors.black45,
                                                    size: 20),
                                                onTap: () =>
                                                    _showLanguagePicker(context),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _staggered(
                                    index: 1,
                                    child: SettingsOptionButton(
                                      leading: const Icon(Icons.restore),
                                      label: 'Restore Purchases',
                                      active: false,
                                      borderColor: Colors.white,
                                      onTap: () => _restorePurchases(context),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _staggered(
                                    index: 3,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SettingsOptionButton(
                                            leading: const Icon(
                                                Icons.privacy_tip_outlined),
                                            label: 'Privacy Policy',
                                            active: false,
                                            onTap: () => showComingSoon(
                                                context, 'Privacy Policy'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SettingsOptionButton(
                                            leading: const Icon(
                                                Icons.description_outlined),
                                            label: 'Terms of Service',
                                            active: false,
                                            onTap: () => showComingSoon(
                                                context, 'Terms of Service'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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

  void _restorePurchases(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        builder: (context, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0).toDouble(),
            child: Transform.scale(scale: v, child: child)),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kDialogColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text('NO PURCHASES FOUND',
                    textAlign: TextAlign.center, style: AppText.cardTitle(Colors.white)),
                const SizedBox(height: 6),
                Text('Nothing to restore on this device yet.',
                    textAlign: TextAlign.center,
                    style: AppText.body(Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 20),
                GameButton(
                  label: 'OK',
                  width: 120,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    const languages = ['English', 'Urdu', 'Arabic', 'Spanish', 'Hindi'];
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Language',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, __, child) {
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(
            scale: 0.9 + anim.value * 0.1,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _kDialogColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Text('LANGUAGE', style: AppText.cardTitle(Colors.white)),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      ...languages.map((lang) {
                        final selected = GameState.instance.language == lang;
                        return InkWell(
                          onTap: () {
                            GameState.instance.setLanguage(lang);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(lang.toUpperCase(),
                                      style: AppText.body(Colors.white)),
                                ),
                                if (selected)
                                  const Icon(Icons.check, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
