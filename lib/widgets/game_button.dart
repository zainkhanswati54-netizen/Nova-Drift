import 'package:flutter/material.dart';

import '../core/app_text.dart';

/// Bordered rectangular button used everywhere in the game UI.
///
/// Two variants, matching the screenshots:
///  - filled  : white background, coloured text (START buttons)
///  - outline : transparent background, coloured border + text (SHOP, SKIN...)
class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.filled = false,
    this.color = Colors.white,
    this.fillTextColor,
    this.enabled = true,
    this.width,
    this.height = 44,
    this.child,
  });

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;

  /// true = white filled button, false = outline button.
  final bool filled;

  /// Border colour (outline) / text colour source.
  final Color color;

  /// Text colour when [filled] (defaults to the screen's onCard colour).
  final Color? fillTextColor;

  final bool enabled;
  final double? width;
  final double height;

  /// Custom content instead of label / icon.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Color fg = filled ? (fillTextColor ?? Colors.black87) : color;
    final Color bg = filled ? Colors.white : Colors.transparent;

    final content = child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              if (label != null) const SizedBox(width: 8),
            ],
            if (label != null)
              Text(label!.toUpperCase(), style: AppText.button(fg)),
          ],
        );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: filled ? fg : color, width: 2.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
