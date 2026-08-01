import 'package:flutter/material.dart';

import '../core/app_text.dart';

/// A bordered settings row-button that smoothly animates between its
/// "on/off" (or selected/unselected) fill state - used for SOUND +
/// LANGUAGE on the Settings screen.
class SettingsOptionButton extends StatefulWidget {
  const SettingsOptionButton({
    super.key,
    required this.leading,
    required this.label,
    required this.onTap,
    this.active = true,
    this.trailing,
    this.borderColor = Colors.white,
  });

  final Widget leading;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Widget? trailing;
  final Color borderColor;

  @override
  State<SettingsOptionButton> createState() => _SettingsOptionButtonState();
}

class _SettingsOptionButtonState extends State<SettingsOptionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 110));

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.active ? Colors.black87 : Colors.white;

    return AnimatedBuilder(
      animation: _press,
      builder: (context, child) {
        final double scale = 1.0 - (_press.value * 0.04);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) => _press.reverse(),
        onTapCancel: () => _press.reverse(),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.active ? Colors.white : Colors.transparent,
            border: Border.all(color: widget.borderColor, width: 2.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              IconTheme(
                data: IconThemeData(color: fg, size: 20),
                child: widget.leading,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.label.toUpperCase(),
                    style: AppText.button(fg)),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
