import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> remove(String key) async => _prefs.remove(key);

  Map<String, int> get stepHistory => {
    for (final key in _prefs.getKeys())
      if (RegExp(r'^steps_\d{4}-\d{2}-\d{2}$').hasMatch(key))
        key.substring(6): _prefs.getInt(key) ?? 0,
  };

  // Daily steps
  Future<void> saveDailySteps(DateTime date, int steps) async {
    await _prefs.setInt(_dateKey(date), steps);
  }

  int getDailySteps(DateTime date) {
    return _prefs.getInt(_dateKey(date)) ?? 0;
  }

  List<int> getWeeklySteps() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return getDailySteps(day);
    });
  }

  List<int> getPreviousWeekSteps() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 13 - i));
      return getDailySteps(day);
    });
  }

  // Total steps (all-time)
  Future<void> saveTotalSteps(int total) async {
    await _prefs.setInt('total_steps', total);
  }

  int getTotalSteps() {
    return _prefs.getInt('total_steps') ?? 0;
  }

  // Step goal
  Future<void> saveStepGoal(int goal) async {
    await _prefs.setInt('step_goal', goal);
  }

  int getStepGoal() {
    return _prefs.getInt('step_goal') ?? 10000;
  }

  // Streak
  Future<void> saveStreak(int days) async {
    await _prefs.setInt('streak', days);
  }

  int getStreak() {
    return _prefs.getInt('streak') ?? 0;
  }

  Future<void> saveLastStreakDate(DateTime date) async {
    await _prefs.setString('last_streak_date', _dateString(date));
  }

  String? getLastStreakDate() {
    return _prefs.getString('last_streak_date');
  }

  // Level history (dates when levels were unlocked)
  Future<void> saveLevelHistory(Map<int, String> history) async {
    await _prefs.setString(
      'level_history',
      jsonEncode(history.map((k, v) => MapEntry(k.toString(), v))),
    );
  }

  Map<int, String> getLevelHistory() {
    final raw = _prefs.getString('level_history');
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(int.parse(k), v as String));
  }

  // User preferences
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  double? getDouble(String key) => _prefs.getDouble(key);
  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> saveJson(String key, Object value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  dynamic getJson(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? null : jsonDecode(raw);
  }

  // Session tracking
  Future<void> saveSessionBaseSteps(int steps) async {
    await _prefs.setInt('session_base_steps', steps);
  }

  int getSessionBaseSteps() {
    return _prefs.getInt('session_base_steps') ?? 0;
  }

  // Helpers
  String _dateKey(DateTime date) => 'steps_${_dateString(date)}';

  String _dateString(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
