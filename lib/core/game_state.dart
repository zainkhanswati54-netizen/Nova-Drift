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

  static const _kGems = 'gems';
  static const _kWorld1 = 'world1Progress';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    gems = prefs.getInt(_kGems) ?? 94;
    world1Progress = prefs.getInt(_kWorld1) ?? 3;
    notifyListeners();
  }

  Future<void> addGems(int amount) async {
    gems += amount;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGems, gems);
  }
}
