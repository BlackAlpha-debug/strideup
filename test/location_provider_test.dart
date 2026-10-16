import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stride_up/models/route_data.dart';
import 'package:stride_up/providers/location_provider.dart';
import 'package:stride_up/services/location_service.dart';
import 'package:stride_up/services/permission_service.dart';
import 'package:stride_up/services/storage_service.dart';

class _LocationPermissions extends PermissionService {
  @override
  Future<bool> isLocationPermissionGranted() async => true;
}

class _Locations extends LocationService {
  final controller = StreamController<Position>.broadcast();

  @override
  Stream<Position> getPositionStream() => controller.stream;

  @override
  double distanceBetween(LatLng a, LatLng b) => Geolocator.distanceBetween(
    a.latitude,
    a.longitude,
    b.latitude,
    b.longitude,
  );
}

Position _position(
  double latitude,
  DateTime timestamp, {
  double accuracy = 5,
}) => Position(
  longitude: 74.3,
  latitude: latitude,
  timestamp: timestamp,
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'route recording filters bad GPS and persists actual step delta',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();
      final locations = _Locations();
      final provider = LocationProvider(
        storage: storage,
        locationService: locations,
        permissions: _LocationPermissions(),
      );
      await provider.init();
      await provider.startTracking(initialSteps: 100);
      final start = DateTime(2026, 10, 15, 8);
      locations.controller.add(_position(31.5, start));
      locations.controller.add(
        _position(31.51, start.add(const Duration(seconds: 1))),
      );
      locations.controller.add(
        _position(
          31.50004,
          start.add(const Duration(seconds: 2)),
          accuracy: 60,
        ),
      );
      locations.controller.add(
        _position(31.50004, start.add(const Duration(seconds: 3))),
      );
      await Future<void>.delayed(Duration.zero);
      await provider.stopTracking(finalSteps: 112);

      expect(provider.savedRoutes, hasLength(1));
      expect(provider.savedRoutes.single.points, hasLength(2));
      expect(provider.savedRoutes.single.steps, 12);
      expect(provider.savedRoutes.single.stepsAvailable, true);

      final restored = LocationProvider(
        storage: storage,
        locationService: _Locations(),
        permissions: _LocationPermissions(),
      );
      await restored.init();
      expect(restored.savedRoutes.single.steps, 12);
      expect(restored.savedRoutes.single.points, hasLength(2));
      await locations.controller.close();
      provider.dispose();
      restored.dispose();
    },
  );

  test(
    'an unfinished route is recovered and visibly marked interrupted',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();
      final draft = RouteData(
        points: const [LatLng(31.5, 74.3)],
        distanceKm: 0,
        duration: const Duration(minutes: 1),
        steps: 0,
        startTime: DateTime(2026, 10, 15, 8),
        stepsAvailable: false,
      );
      await storage.saveJson('route_draft_v1', draft.toJson());
      final provider = LocationProvider(
        storage: storage,
        locationService: _Locations(),
        permissions: _LocationPermissions(),
      );
      await provider.init();
      expect(provider.savedRoutes.single.interrupted, true);
      expect(provider.savedRoutes.single.stepsAvailable, false);
      expect(storage.getJson('route_draft_v1'), isNull);
      provider.dispose();
    },
  );
}
