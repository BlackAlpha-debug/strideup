import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StepTrackingService {
  static const _channel = MethodChannel('stride_up/steps');
  static const _events = EventChannel('stride_up/step_events');
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  Stream<Map<dynamic, dynamic>> get events => _events
      .receiveBroadcastStream()
      .map((event) => Map<dynamic, dynamic>.from(event as Map));
  Future<Map<dynamic, dynamic>> configure({
    required bool enabled,
    required bool notifications,
    required int accent,
    required Map<String, int> history,
    required int total,
    double weightKg = 70,
    double stepLengthCm = 76.2,
    String mode = 'responsive',
    double sensitivity = 0.6,
  }) async =>
      await _channel.invokeMapMethod<dynamic, dynamic>('configure', {
        'enabled': enabled,
        'notifications': notifications,
        'accent': accent,
        'history': history,
        'total': total,
        'weightKg': weightKg,
        'stepLengthCm': stepLengthCm,
        'mode': mode,
        'sensitivity': sensitivity,
      }) ??
      {};

  Future<Map<dynamic, dynamic>> appInfo() async =>
      await _channel.invokeMapMethod<dynamic, dynamic>('appInfo') ?? {};
}
