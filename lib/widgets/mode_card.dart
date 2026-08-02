import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';

/// One of the three big mode cards (CLASSIC / ENDLESS / RACE).
class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.palette,
    required this.title,
    required this.description,
    required this.middle,
    required this.actions,
  });

  final GamePalette palette;
  final String title;
  final String description;

  /// Icon / stat shown between title and description.
  final Widget middle;

  /// Buttons at the bottom of the card.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title.toUpperCase(), style: AppText.cardTitle(palette.onCard)),
          const SizedBox(height: 18),
          SizedBox(height: 56, child: Center(child: middle)),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppText.body(palette.onCard),
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            actions[i],
          ],
        ],
      ),
    );
  }
}
