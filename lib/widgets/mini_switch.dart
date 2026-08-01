import 'package:flutter/material.dart';

/// Compact animated on/off pill (a lightweight custom Switch) that reads
/// well against the bordered [SettingsOptionButton] rows.
class MiniSwitch extends StatelessWidget {
  const MiniSwitch({super.key, required this.value, required this.onColor});

  final bool value;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: 46,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? onColor : Colors.black26,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
      ),
    );
  }
}
