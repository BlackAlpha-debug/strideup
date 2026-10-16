import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stride_up/models/route_data.dart';
import 'package:stride_up/utils/step_calculator.dart';
import 'package:stride_up/utils/units.dart';

void main() {
  test('distance and calories use the saved body measurements', () {
    expect(stepsToDistanceKm(1000, strideM: .8), closeTo(.8, .0001));
    expect(
      stepsToCalories(1000, weightKg: 80, strideM: .8),
      closeTo(32, .0001),
    );
    expect(displayDistance(1, false), closeTo(.621371, .000001));
    expect(displayPace(const Duration(minutes: 5), 1, true), '5:00 /km');
  });

  test('rolling week ends today and retains calendar day labels', () {
    final days = rollingWeekDates(DateTime(2026, 10, 15));
    expect(days.first, DateTime(2026, 10, 9));
    expect(days.last, DateTime(2026, 10, 15));
    expect(weekdayLabel(days.last), 'Thu');
  });

  test('recorded route survives JSON persistence', () {
    final route = RouteData(
      points: const [LatLng(31.5, 74.3), LatLng(31.5001, 74.3001)],
      distanceKm: .014,
      duration: const Duration(minutes: 2),
      steps: 183,
      startTime: DateTime(2026, 10, 15, 8, 30),
    );
    final restored = RouteData.fromJson(route.toJson());
    expect(restored.points, hasLength(2));
    expect(restored.distanceKm, route.distanceKm);
    expect(restored.duration, route.duration);
    expect(restored.steps, 183);
    expect(restored.startTime, route.startTime);
  });
}
