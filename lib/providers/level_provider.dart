import 'package:flutter/foundation.dart';
import '../models/level_data.dart';
import '../services/storage_service.dart';
import '../utils/step_calculator.dart';

class LevelProvider extends ChangeNotifier {
  final StorageService storage;

  LevelInfo _currentLevel = LevelInfo.all.first;
  double _progress = 0.0;
  int _xpToNext = 0;
  int _totalXP = 0;
  int _streak = 0;
  Map<int, String> _levelHistory = {};

  LevelProvider({required this.storage});

  LevelInfo get currentLevel => _currentLevel;
  double get progress => _progress;
  int get xpToNext => _xpToNext;
  int get totalXP => _totalXP;
  int get streak => _streak;
  Map<int, String> get levelHistory => Map.unmodifiable(_levelHistory);

  List<LevelInfo> get allLevels => LevelInfo.all;

  String levelStatus(int level) {
    if (level < _currentLevel.level) return 'completed';
    if (level == _currentLevel.level) return 'current';
    return 'locked';
  }

  String? levelDate(int level) => _levelHistory[level];

  Future<void> init() async {
    _streak = storage.getStreak();
    _levelHistory = storage.getLevelHistory();
    updateFromSteps(storage.getTotalSteps());
  }

  void updateFromSteps(int totalSteps) {
    final result = levelFromTotalSteps(totalSteps);
    final previousLevel = _currentLevel.level;

    _currentLevel = result.current;
    _progress = result.progress;
    _xpToNext = result.xpToNext;
    _totalXP = stepsToXP(totalSteps);
    _streak = storage.getStreak();

    if (_currentLevel.level > previousLevel) {
      _onLevelUp(_currentLevel.level);
    }

    notifyListeners();
  }

  void _onLevelUp(int newLevel) {
    final now = DateTime.now();
    final dateStr = '${_monthName(now.month)} ${now.day}';
    _levelHistory[newLevel] = dateStr;
    storage.saveLevelHistory(_levelHistory);
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
