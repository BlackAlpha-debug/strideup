import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStepPermission() async {
    if (kIsWeb) return false;
    try {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    if (kIsWeb) return false;
    try {
      final status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isStepPermissionGranted() async {
    if (kIsWeb) return false;
    try {
      return await Permission.activityRecognition.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    if (kIsWeb) return false;
    try {
      return await Permission.locationWhenInUse.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isStepPermissionDenied() async {
    if (kIsWeb) return false;
    try {
      return await Permission.activityRecognition.isPermanentlyDenied;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLocationPermissionDenied() async {
    if (kIsWeb) return false;
    try {
      return await Permission.locationWhenInUse.isPermanentlyDenied;
    } catch (_) {
      return false;
    }
  }

  Future<void> openSettings() async {
    if (kIsWeb) return;
    try {
      await openAppSettings();
    } catch (_) {}
  }
}
