import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stride_up/providers/step_provider.dart';
import 'package:stride_up/services/permission_service.dart';
import 'package:stride_up/services/step_tracking_service.dart';
import 'package:stride_up/services/storage_service.dart';

class FakeTracking extends StepTrackingService {
  final controller = StreamController<Map<dynamic, dynamic>>.broadcast();
  final configurations = <Map<String, dynamic>>[];
  Map<dynamic, dynamic> snapshot = {
    'today': 0,
    'total': 0,
    'history': <String, int>{},
    'running': true,
  };
  @override
  bool get supported => true;
  @override
  Stream<Map<dynamic, dynamic>> get events => controller.stream;
  @override
  Future<Map<dynamic, dynamic>> configure({
    required bool enabled,
    required bool notifications,
    required int accent,
    required Map<String, int> history,
    required int total,
    double weightKg = 70,
    double stepLengthCm = 76.2,
    String mode = 'responsive',
    double sensitivity = .6,
  }) async {
    configurations.add({
      'enabled': enabled,
      'notifications': notifications,
      'weightKg': weightKg,
      'stepLengthCm': stepLengthCm,
      'mode': mode,
      'sensitivity': sensitivity,
    });
    return snapshot;
  }
}

class FakePermissions extends PermissionService {
  bool granted = true;
  @override
  Future<bool> isStepPermissionGranted() async => granted;
  @override
  Future<bool> isStepPermissionDenied() async => !granted;
  @override
  Future<bool> requestStepPermission() async => granted;
}

String dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StorageService storage;
  late FakeTracking tracking;
  late FakePermissions permissions;
  late StepProvider provider;
  setUp(() async {
    SharedPreferences.setMockInitialValues({'notification_prompted': true});
    storage = StorageService();
    await storage.init();
    tracking = FakeTracking();
    permissions = FakePermissions();
    provider = StepProvider(
      storage: storage,
      tracking: tracking,
      permissions: permissions,
    );
    await provider.init();
  });
  tearDown(() async {
    await provider.stopForLogout();
    provider.dispose();
    await tracking.controller.close();
  });

  test(
    'Counting off persists and does not turn notification preference off',
    () async {
      await provider.setCountingEnabled(false);
      expect(tracking.configurations.last['enabled'], false);
      expect(provider.notificationsEnabled, true);
      expect(storage.getBool('step_counting'), false);
      final restored = StepProvider(
        storage: storage,
        tracking: tracking,
        permissions: permissions,
      );
      expect(restored.countingEnabled, false);
      restored.dispose();
      await provider.setCountingEnabled(true);
      expect(tracking.configurations.last['enabled'], true);
    },
  );

  test('Notification off keeps counting enabled and persists', () async {
    await provider.setNotificationsEnabled(false);
    expect(tracking.configurations.last, containsPair('enabled', true));
    expect(tracking.configurations.last, containsPair('notifications', false));
    expect(storage.getBool('push_notifications'), false);
  });

  test(
    'Denied activity permission cannot re-enable a paused counter',
    () async {
      await provider.setCountingEnabled(false);
      permissions.granted = false;
      await provider.setCountingEnabled(true);
      expect(provider.countingEnabled, false);
      expect(provider.permissionDenied, true);
      expect(provider.busy, false);
    },
  );

  test(
    'Duplicate snapshots and midnight preserve lifetime and historical totals',
    () async {
      final today = dateKey(DateTime.now());
      final yesterday = dateKey(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      tracking.snapshot = {
        'today': 5,
        'total': 10005,
        'history': {yesterday: 10000, today: 5},
        'running': true,
      };
      tracking.controller.add(tracking.snapshot);
      tracking.controller.add(tracking.snapshot);
      await Future<void>.delayed(Duration.zero);
      await provider.stopForLogout();
      expect(provider.todaySteps, 5);
      expect(provider.calories, closeTo(0.13335, 0.00001));
      expect(provider.totalSteps, 10005);
      expect(storage.getTotalSteps(), 10005);
      expect(storage.getDailySteps(DateTime.now()), 5);
      expect(provider.weeklyTotal, 10005);
      expect(provider.streak, 1);
    },
  );

  test(
    'Logout stops native tracking but keeps the saved user preference',
    () async {
      await provider.stopForLogout();
      expect(tracking.configurations.last['enabled'], false);
      expect(provider.countingEnabled, true);
    },
  );
}
