import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<SharedPreferences> _p() => SharedPreferences.getInstance();

  static Future<String> todayKey() async {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<Map<String, dynamic>> getJson(String key) async {
    final p = await _p();
    final raw = p.getString(key);
    if (raw == null || raw.isEmpty) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    final p = await _p();
    await p.setString(key, jsonEncode(value));
  }

  static Future<int> getInt(String key, {int def = 0}) async {
    final p = await _p();
    return p.getInt(key) ?? def;
  }

  static Future<void> setInt(String key, int value) async {
    final p = await _p();
    await p.setInt(key, value);
  }

  static Future<String?> getString(String key) async {
    final p = await _p();
    return p.getString(key);
  }

  static Future<void> setString(String key, String value) async {
    final p = await _p();
    await p.setString(key, value);
  }
}
