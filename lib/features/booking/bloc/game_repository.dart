import 'package:shared_preferences/shared_preferences.dart';

class GameRepository {
  static const _bestDistanceKey = 'endless_drive_best_distance';
  static const _totalCoinsKey = 'endless_drive_total_coins';
  static const _gamesPlayedKey = 'endless_drive_games_played';

  Future<int> getBestDistance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_bestDistanceKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> saveBestDistance(int meters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bestDistanceKey, meters);
    } catch (_) {}
  }

  Future<int> getTotalCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_totalCoinsKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> addTotalCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_totalCoinsKey) ?? 0;
      await prefs.setInt(_totalCoinsKey, current + coins);
    } catch (_) {}
  }

  Future<int> getGamesPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_gamesPlayedKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> incrementGamesPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_gamesPlayedKey) ?? 0;
      await prefs.setInt(_gamesPlayedKey, current + 1);
    } catch (_) {}
  }
}
