import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_data.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';

class LocationProvider extends ChangeNotifier {
  static const _routesKey = 'saved_routes_v1';
  static const _draftKey = 'route_draft_v1';
  final StorageService storage;
  final LocationService _locationService;
  final PermissionService _permissions;
  StreamSubscription<Position>? _positionSub;
  LatLng? _currentPosition;
  Position? _lastAccepted;
  bool _isTracking = false;
  bool _hasPermission = false;
  bool _permissionDenied = false;
  String? _error;
  RouteData? _currentRoute;
  RouteData? _selectedRoute;
  List<RouteData> _savedRoutes = [];
  final List<LatLng> _routePoints = [];
  DateTime? _trackingStartTime;
  int? _startSteps;

  LocationProvider({
    required this.storage,
    LocationService? locationService,
    PermissionService? permissions,
  }) : _locationService = locationService ?? LocationService(),
       _permissions = permissions ?? PermissionService();

  LatLng? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get hasPermission => _hasPermission;
  bool get permissionDenied => _permissionDenied;
  String? get error => _error;
  RouteData? get currentRoute => _currentRoute;
  RouteData? get selectedRoute => _selectedRoute;
  List<RouteData> get savedRoutes => List.unmodifiable(_savedRoutes);
  List<LatLng> get routePoints => List.unmodifiable(
    _isTracking ? _routePoints : (_selectedRoute?.points ?? const <LatLng>[]),
  );
  List<LatLng> get heatPoints =>
      _savedRoutes.expand((route) => route.points).toList();

  Future<void> init() async {
    _hasPermission = await _permissions.isLocationPermissionGranted();
    _loadRoutes();
    final draft = storage.getJson(_draftKey);
    if (draft is Map) {
      try {
        final recovered = RouteData.fromJson(
          Map<String, dynamic>.from(draft),
          recovered: true,
        );
        if (recovered.points.isNotEmpty) {
          _savedRoutes.insert(0, recovered);
          _selectedRoute = recovered;
          await _persistRoutes();
        }
      } catch (_) {
        _error = 'A damaged unfinished route was discarded.';
      }
      await storage.remove(_draftKey);
    }
    notifyListeners();
  }

  void _loadRoutes() {
    final raw = storage.getJson(_routesKey);
    if (raw is! List) return;
    _savedRoutes =
        raw
            .map(
              (item) =>
                  RouteData.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));
    _selectedRoute = _savedRoutes.firstOrNull;
  }

  Future<void> _persistRoutes() => storage.saveJson(
    _routesKey,
    _savedRoutes.take(100).map((route) => route.toJson()).toList(),
  );

  Future<bool> requestPermission() async {
    _hasPermission = await _permissions.requestLocationPermission();
    if (!_hasPermission) {
      _permissionDenied = await _permissions.isLocationPermissionDenied();
    }
    notifyListeners();
    return _hasPermission;
  }

  Future<void> centerOnUser() async {
    if (!_hasPermission && !await requestPermission()) return;
    try {
      final position = await _locationService.getCurrentPosition();
      _currentPosition = _locationService.positionToLatLng(position);
      _error = null;
    } catch (_) {
      _error = 'Could not get your current location.';
    }
    notifyListeners();
  }

  Future<void> startTracking({required int initialSteps}) async {
    if (_isTracking) return;
    if (!_hasPermission && !await requestPermission()) return;
    _isTracking = true;
    _error = null;
    _routePoints.clear();
    _lastAccepted = null;
    _trackingStartTime = DateTime.now();
    _startSteps = initialSteps;
    _currentRoute = null;
    notifyListeners();
    _positionSub = _locationService.getPositionStream().listen(
      (position) => _acceptPosition(position, initialSteps),
      onError: (_) {
        _error = 'Route location updates stopped.';
        unawaited(stopTracking());
      },
    );
  }

  Future<void> _acceptPosition(Position position, int initialSteps) async {
    if (!_isTracking || position.accuracy > 40) return;
    if (_lastAccepted != null) {
      final metres = Geolocator.distanceBetween(
        _lastAccepted!.latitude,
        _lastAccepted!.longitude,
        position.latitude,
        position.longitude,
      );
      final seconds =
          position.timestamp
              .difference(_lastAccepted!.timestamp)
              .inMilliseconds /
          1000;
      if (seconds <= 0 || metres / seconds > 8 || metres < 2) return;
    }
    _lastAccepted = position;
    _currentPosition = _locationService.positionToLatLng(position);
    _routePoints.add(_currentPosition!);
    _updateRouteData(initialSteps, stepsAvailable: false);
    if (_currentRoute != null) {
      await storage.saveJson(_draftKey, _currentRoute!.toJson());
    }
    notifyListeners();
  }

  Future<void> stopTracking({int? finalSteps}) async {
    if (!_isTracking) return;
    _isTracking = false;
    await _positionSub?.cancel();
    _positionSub = null;
    _updateRouteData(
      finalSteps ?? _startSteps ?? 0,
      stepsAvailable: finalSteps != null,
    );
    if (_currentRoute != null && _currentRoute!.points.isNotEmpty) {
      _savedRoutes.insert(0, _currentRoute!);
      _selectedRoute = _currentRoute;
      await _persistRoutes();
    }
    await storage.remove(_draftKey);
    notifyListeners();
  }

  void _updateRouteData(int currentSteps, {required bool stepsAvailable}) {
    if (_trackingStartTime == null) return;
    double metres = 0;
    for (var i = 1; i < _routePoints.length; i++) {
      metres += _locationService.distanceBetween(
        _routePoints[i - 1],
        _routePoints[i],
      );
    }
    _currentRoute = RouteData(
      points: List.from(_routePoints),
      distanceKm: metres / 1000,
      duration: DateTime.now().difference(_trackingStartTime!),
      steps: stepsAvailable
          ? (currentSteps - (_startSteps ?? currentSteps)).clamp(0, 1 << 31)
          : 0,
      startTime: _trackingStartTime!,
      stepsAvailable: stepsAvailable,
    );
  }

  void selectRoute(RouteData route) {
    _selectedRoute = route;
    notifyListeners();
  }

  Future<void> deleteRoute(RouteData route) async {
    _savedRoutes.removeWhere((item) => item.id == route.id);
    if (_selectedRoute?.id == route.id) {
      _selectedRoute = _savedRoutes.firstOrNull;
    }
    await _persistRoutes();
    notifyListeners();
  }

  Future<void> openSettings() => _permissions.openSettings();
  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
