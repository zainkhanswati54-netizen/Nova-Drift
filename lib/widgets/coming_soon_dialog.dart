import 'package:flutter/material.dart';

import '../core/app_text.dart';
import 'game_button.dart';

/// Shows a "COMING SOON" dialog styled like the game's cards.
void showComingSoon(BuildContext context, String feature) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF13315C),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top_rounded,
                color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              feature.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.cardTitle(Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'COMING SOON!',
              style: AppText.body(Colors.white.withValues(alpha: 0.8)),
            ),
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
  );
}
