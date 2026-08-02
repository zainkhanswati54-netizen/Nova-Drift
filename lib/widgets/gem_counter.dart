import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/game_state.dart';
import 'coming_soon_dialog.dart';

/// Top-right gem counter pill with the purple gem and "+" buy button.
class GemCounter extends StatelessWidget {
  const GemCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState.instance,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dark pill with gem + count
            Container(
              height: 36,
              padding: const EdgeInsets.only(left: 4, right: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Gem(size: 30),
                  const SizedBox(width: 8),
                  Text(
                    '${GameState.instance.gems}',
                    style: AppText.cardTitle(Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // "+" buy button
            SizedBox(
              width: 36,
              height: 36,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: () => showComingSoon(context, 'Gem Shop'),
                  borderRadius: BorderRadius.circular(4),
                  child: const Icon(Icons.add, color: Colors.black87, size: 24),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Simple purple gem drawn with a rotated rounded square - no asset needed.
class _Gem extends StatelessWidget {
  const _Gem({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Container(
            width: size * 0.58,
            height: size * 0.58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB35CF0), Color(0xFF7A1FC2)],
              ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
