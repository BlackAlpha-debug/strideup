import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final StorageService storage;

  UserProfile _profile = const UserProfile();

  UserProvider({required this.storage});

  UserProfile get profile => _profile;
  String get name => _profile.name;
  int get stepGoal => _profile.stepGoal;
  bool get useKilometers => _profile.useKilometers;
  bool get locationTracking => _profile.locationTracking;
  bool get pushNotifications => _profile.pushNotifications;
  double get weightKg => storage.getDouble('weight_kg') ?? 70;
  double get stepLengthCm => storage.getDouble('step_length_cm') ?? 76.2;

  Future<void> updateMeasurements({
    required double weightKg,
    required double stepLengthCm,
  }) async {
    if (!weightKg.isFinite ||
        weightKg < 20 ||
        weightKg > 350 ||
        !stepLengthCm.isFinite ||
        stepLengthCm < 20 ||
        stepLengthCm > 150) {
      throw ArgumentError('Enter weight 20–350 kg and step length 20–150 cm.');
    }
    await storage.saveDouble('weight_kg', weightKg);
    await storage.saveDouble('step_length_cm', stepLengthCm);
    notifyListeners();
  }

  Future<void> init() async {
    _profile = UserProfile(
      name: storage.getString('user_name') ?? 'Alex Rivera',
      stepGoal: storage.getStepGoal(),
      useKilometers: storage.getBool('use_kilometers') ?? true,
      locationTracking: storage.getBool('location_tracking') ?? true,
      pushNotifications: storage.getBool('push_notifications') ?? true,
    );
    notifyListeners();
  }

  Future<void> updateStepGoal(int goal) async {
    _profile = _profile.copyWith(stepGoal: goal);
    await storage.saveStepGoal(goal);
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _profile = _profile.copyWith(name: name);
    await storage.saveString('user_name', name);
    notifyListeners();
  }

  Future<void> toggleUnits() async {
    _profile = _profile.copyWith(useKilometers: !_profile.useKilometers);
    await storage.saveBool('use_kilometers', _profile.useKilometers);
    notifyListeners();
  }

  Future<void> setLocationTracking(bool value) async {
    _profile = _profile.copyWith(locationTracking: value);
    await storage.saveBool('location_tracking', value);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool value) async {
    _profile = _profile.copyWith(pushNotifications: value);
    await storage.saveBool('push_notifications', value);
    notifyListeners();
  }
}
