import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../services/step_tracking_service.dart';
import '../services/storage_service.dart';
import '../utils/step_calculator.dart';
import '../utils/units.dart';

class StepProvider extends ChangeNotifier with WidgetsBindingObserver {
  final StorageService storage;
  final StepTrackingService _tracking;
  final PermissionService _permissions;
  StreamSubscription<Map<dynamic, dynamic>>? _subscription;
  Future<void> _saveQueue = Future.value();
  bool _initialized = false;
  bool _sessionActive = false;
  bool _disposed = false;
  bool _busy = false;
  bool _enabled;
  bool _notifications;
  bool _hasPermission = false;
  bool _permissionDenied = false;
  bool _running = false;
  bool _notificationGranted = false;
  bool _foreground = true;
  int _todaySteps = 0;
  int _totalSteps = 0;
  int _streak = 0;
  int _accent = 0xFF00F2FF;
  String? _error;
  int _undatedSteps = 0;
  String _sensorMode = '';
  String _appVersion = '1.0.0';
  String _buildNumber = '1';
  Map<String, int> _history = {};
  ValueChanged<int>? onTotalChanged;

  StepProvider({
    required this.storage,
    StepTrackingService? tracking,
    PermissionService? permissions,
  }) : _tracking = tracking ?? StepTrackingService(),
       _permissions = permissions ?? PermissionService(),
       _enabled = storage.getBool('step_counting') ?? true,
       _notifications = storage.getBool('push_notifications') ?? true {
    _history = storage.stepHistory;
    _todaySteps = storage.getDailySteps(DateTime.now());
    _totalSteps = storage.getTotalSteps();
    _streak = storage.getStreak();
  }

  int get todaySteps => _todaySteps;
  int get totalSteps => _totalSteps;
  int get streak => _streak;
  double get weightKg => storage.getDouble('weight_kg') ?? 70;
  double get strideM => (storage.getDouble('step_length_cm') ?? 76.2) / 100;
  double get calories =>
      stepsToCalories(_todaySteps, weightKg: weightKg, strideM: strideM);
  double get distanceKm => stepsToDistanceKm(_todaySteps, strideM: strideM);
  int get undatedSteps => _undatedSteps;
  String get sensorMode => _sensorMode;
  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;
  String get trackingMode => storage.getString('tracking_mode') ?? 'responsive';
  double get sensitivity => storage.getDouble('step_sensitivity') ?? 0.6;
  Future<void> updateTrackingMode(String mode, {double? sensitivity}) async {
    if (_busy || !['battery', 'responsive', 'sensitive'].contains(mode)) return;
    _busy = true;
    _notify();
    try {
      await storage.saveString('tracking_mode', mode);
      if (sensitivity != null) {
        await storage.saveDouble(
          'step_sensitivity',
          sensitivity.clamp(0.35, 1.2),
        );
      }
      await refreshPreferences();
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> refreshPreferences() async {
    if (_initialized && supported) await _configure();
    _notify();
  }

  int get activeMinutes => stepsToActiveMinutes(_todaySteps);
  String get pedestrianStatus => _running ? 'tracking' : 'paused';
  bool get hasPermission => _hasPermission;
  bool get permissionDenied => _permissionDenied;
  bool get countingEnabled => _enabled;
  bool get notificationsEnabled => _notifications;
  bool get notificationGranted => _notificationGranted;
  bool get busy => _busy;
  String? get error => _error;
  bool get supported => _tracking.supported;
  String get statusText => !_enabled
      ? 'Step counting is paused'
      : _error ??
            (!_hasPermission
                ? 'Allow physical activity to count steps'
                : _notifications && _notificationGranted
                ? _undatedSteps > 0
                      ? 'Background counting is on • $_undatedSteps steps could not be assigned to a date'
                      : 'Background step counting is on'
                : 'Counting while the app is open');

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  List<DateTime> get weeklyDates => rollingWeekDates(DateTime.now());
  List<int> _week(int offset) => rollingWeekDates(
    DateTime.now(),
    weeksAgo: offset ~/ 7,
  ).map((day) => _history[_dateKey(day)] ?? 0).toList();
  List<int> get weeklySteps => _week(0);
  int get weeklyTotal => weeklySteps.fold(0, (a, b) => a + b);
  int get weeklyTrendPercent {
    final previous = _week(7).fold(0, (a, b) => a + b);
    return previous == 0
        ? 0
        : ((weeklyTotal - previous) / previous * 100).round();
  }

  double get weeklyCaloriesAvg {
    final days = weeklySteps.where((s) => s > 0).length;
    return days == 0
        ? 0
        : stepsToCalories(weeklyTotal, weightKg: weightKg, strideM: strideM) /
              days;
  }

  double get weeklyDistanceKm =>
      stepsToDistanceKm(weeklyTotal, strideM: strideM);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _sessionActive = true;
    WidgetsBinding.instance.addObserver(this);
    if (!supported) {
      _error = 'Step tracking is available on Android.';
      _notify();
      return;
    }
    await _refreshPermissions();
    if (!_sessionActive || _disposed) return;
    try {
      final info = await _tracking.appInfo();
      _appVersion = info['version'] as String? ?? _appVersion;
      _buildNumber = info['build'] as String? ?? _buildNumber;
    } catch (_) {}
    await _configure();
    if (_disposed || !_sessionActive) return;
    _subscription = _tracking.events.listen(
      _accept,
      onError: (Object error) {
        _error = 'Step tracking is unavailable. Try enabling it again.';
        _notify();
      },
    );
  }

  Future<void> _refreshPermissions() async {
    _hasPermission = await _permissions.isStepPermissionGranted();
    _permissionDenied = await _permissions.isStepPermissionDenied();
  }

  Future<void> requestPermission() => setCountingEnabled(true);

  Future<void> setCountingEnabled(bool value) async {
    if (_busy || !supported) return;
    _busy = true;
    _notify();
    try {
      if (value) {
        _hasPermission = await _permissions.requestStepPermission();
        _permissionDenied = await _permissions.isStepPermissionDenied();
        if (!_hasPermission) return;
      }
      _enabled = value;
      await storage.saveBool('step_counting', value);
      if (value &&
          _notifications &&
          storage.getBool('notification_prompted') != true) {
        await _requestNotifications();
      }
      await _configure();
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_busy || !supported) return;
    _busy = true;
    _notify();
    try {
      if (value) {
        final granted = await _requestNotifications();
        if (!granted) {
          _notifications = false;
          await storage.saveBool('push_notifications', false);
          await _configure();
          _error = 'Notifications are blocked. Allow them in Android settings.';
          return;
        }
      }
      _notifications = value;
      await storage.saveBool('push_notifications', value);
      await _configure();
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<bool> _requestNotifications() async {
    await storage.saveBool('notification_prompted', true);
    _notificationGranted = (await Permission.notification.request()).isGranted;
    return _notificationGranted;
  }

  Future<void> _promptOnFirstSteps() async {
    if (_busy ||
        !_sessionActive ||
        !_foreground ||
        !_enabled ||
        !_notifications ||
        storage.getBool('notification_prompted') == true) {
      return;
    }
    _busy = true;
    try {
      await _requestNotifications();
      await _configure();
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> setAccent(int color) async {
    if (_accent == color) return;
    _accent = color;
    if (_initialized && supported) await _configure();
  }

  Future<void> _configure({bool? enabled}) async {
    try {
      final snapshot = await _tracking.configure(
        enabled: enabled ?? (_enabled && _sessionActive),
        notifications: _notifications,
        accent: _accent,
        history: storage.stepHistory,
        total: storage.getTotalSteps(),
        weightKg: weightKg,
        stepLengthCm: strideM * 100,
        mode: trackingMode,
        sensitivity: sensitivity,
      );
      _accept(snapshot);
    } catch (_) {
      _error =
          'Could not start step tracking. Check Android permissions and try again.';
      _notify();
    }
  }

  void _accept(Map<dynamic, dynamic> snapshot) {
    if (_disposed || snapshot.isEmpty) return;
    final previous = _totalSteps;
    _todaySteps = (snapshot['today'] as num?)?.toInt() ?? _todaySteps;
    _totalSteps = (snapshot['total'] as num?)?.toInt() ?? _totalSteps;
    _running = snapshot['running'] == true;
    _undatedSteps = (snapshot['undated'] as num?)?.toInt() ?? 0;
    _sensorMode = snapshot['sensorMode'] as String? ?? '';
    _notificationGranted = snapshot['notificationGranted'] == true;
    _error = snapshot['error'] as String?;
    final history = snapshot['history'] as Map?;
    if (history != null) {
      _history = history.map(
        (key, value) => MapEntry(key as String, (value as num).toInt()),
      );
      final captured = Map<String, int>.from(_history);
      final total = _totalSteps;
      _saveQueue = _saveQueue
          .then((_) async {
            for (final entry in captured.entries) {
              final date = DateTime.parse(entry.key);
              if (storage.getDailySteps(date) != entry.value) {
                await storage.saveDailySteps(date, entry.value);
              }
            }
            await storage.saveTotalSteps(total);
            await _updateStreak(captured);
            if (!_disposed) {
              onTotalChanged?.call(total);
              _notify();
            }
          })
          .catchError((Object error) {
            debugPrint('Could not save step summary: $error');
          });
    }
    _notify();
    if (_totalSteps > previous) unawaited(_promptOnFirstSteps());
  }

  Future<void> _updateStreak(Map<String, int> history) async {
    var date = DateTime.now();
    final goal = storage.getStepGoal();
    if ((history[_dateKey(date)] ?? 0) < goal) {
      date = date.subtract(const Duration(days: 1));
    }
    final last = date;
    var streak = 0;
    while ((history[_dateKey(date)] ?? 0) >= goal) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    _streak = streak;
    await storage.saveStreak(streak);
    if (streak > 0) await storage.saveLastStreakDate(last);
  }

  Future<void> stopForLogout() async {
    _sessionActive = false;
    if (supported) await _configure(enabled: false);
    await _subscription?.cancel();
    _subscription = null;
    _initialized = false;
    WidgetsBinding.instance.removeObserver(this);
    await _saveQueue;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && _sessionActive && supported && !_busy) {
      unawaited(_resume());
    }
  }

  Future<void> _resume() async {
    await _refreshPermissions();
    await _configure();
  }

  Future<void> openSettings() => _permissions.openSettings();
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }
}
