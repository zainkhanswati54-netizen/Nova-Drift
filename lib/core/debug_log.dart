import 'package:flutter/foundation.dart';

/// A tiny in-memory log buffer so what's happening (and any error that
/// happens) shows up *on the device screen* via [DebugOverlay], not
/// only in a PC-connected `flutter run` terminal or `adb logcat`.
///
/// This exists specifically to debug the "blue screen on every mode"
/// report: with this wired into main.dart's error handlers and the
/// game's own defensive try/catch blocks, whatever actually goes
/// wrong will be readable directly on the phone.
class DebugLog {
  DebugLog._();
  static final DebugLog instance = DebugLog._();

  final ValueNotifier<List<String>> lines = ValueNotifier<List<String>>([]);
  static const int _maxLines = 300;

  void add(String message) {
    final now = DateTime.now();
    final ts = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    final entry = '[$ts] $message';
    final updated = [...lines.value, entry];
    if (updated.length > _maxLines) {
      updated.removeRange(0, updated.length - _maxLines);
    }
    lines.value = updated;
    debugPrint(message);
  }

  void clear() => lines.value = [];
}
