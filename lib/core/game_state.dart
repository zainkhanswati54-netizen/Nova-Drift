import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple persisted game state (gems, progress).
/// Expand this as gameplay systems come online.
class GameState extends ChangeNotifier {
  GameState._();

  static final GameState instance = GameState._();

  int gems = 94;
  int world1Progress = 3; // percent
  int specialProgress = 0; // percent

  /// Best distance (in world units) ever reached in Endless mode.
  int endlessBest = 0;

  bool soundOn = true;
  String language = 'English';

  static const _kGems = 'gems';
  static const _kWorld1 = 'world1Progress';
  static const _kSound = 'soundOn';
  static const _kLanguage = 'language';
  static const _kEndlessBest = 'endlessBest';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    gems = prefs.getInt(_kGems) ?? 94;
    world1Progress = prefs.getInt(_kWorld1) ?? 3;
    endlessBest = prefs.getInt(_kEndlessBest) ?? 0;
    soundOn = prefs.getBool(_kSound) ?? true;
    language = prefs.getString(_kLanguage) ?? 'English';
    notifyListeners();
  }

  /// Returns true if [value] beat the previous best (a "NEW BEST!").
  Future<bool> reportEndlessDistance(int value) async {
    if (value <= endlessBest) return false;
    endlessBest = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kEndlessBest, value);
    return true;
  }

  Future<void> setWorld1Progress(int value) async {
    if (value <= world1Progress) return;
    world1Progress = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWorld1, value);
  }

  Future<void> addGems(int amount) async {
    gems += amount;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGems, gems);
  }

  Future<void> setSoundOn(bool value) async {
    soundOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSound, value);
  }

  Future<void> setLanguage(String value) async {
    language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, value);
  }
}
