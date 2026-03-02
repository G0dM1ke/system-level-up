import '../models/quest.dart';
import 'prefs.dart';

class XpService {
  static const totalXpKey = 'total_xp';
  static const streakKey = 'streak_days'; // comma-separated dates where minimum day achieved
  static const minDayKeyPrefix = 'min_day_'; // min_day_YYYY-MM-DD

  static int levelFromTotalXp(int totalXp) => (totalXp ~/ 250) + 1;
  static int xpIntoLevel(int totalXp) => totalXp % 250;
  static int xpToNextLevel(int totalXp) => 250 - xpIntoLevel(totalXp);

  static String dayStateKey(String day) => 'day_state_$day'; // quest completion + easy mode + day xp

  static Future<Map<String, dynamic>> getDayState(String day) async {
    return Prefs.getJson(dayStateKey(day));
  }

  static Future<void> saveDayState(String day, Map<String, dynamic> state) async {
    await Prefs.setJson(dayStateKey(day), state);
  }

  static int questXp(Quest q, {required bool easyMode}) => easyMode ? q.easyXp : q.xp;

  static Future<int> getTotalXp() async => Prefs.getInt(totalXpKey, def: 0);
  static Future<void> setTotalXp(int v) async => Prefs.setInt(totalXpKey, v);

  static Future<int> getStreak() async {
    final today = await Prefs.todayKey();
    // Simple streak: count consecutive days ending today where min_day_YYYY-MM-DD == 1
    int streak = 0;
    DateTime cursor = DateTime.parse(today);
    while (true) {
      final key = '$minDayKeyPrefix${_dateKey(cursor)}';
      final val = await Prefs.getInt(key, def: 0);
      if (val != 1) break;
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<void> updateMinDayAchieved({required String day, required bool achieved}) async {
    await Prefs.setInt('$minDayKeyPrefix$day', achieved ? 1 : 0);
  }
}
