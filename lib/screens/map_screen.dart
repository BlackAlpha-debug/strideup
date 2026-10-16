import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/route_data.dart';
import '../providers/location_provider.dart';
import '../providers/step_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/units.dart';
import '../widgets/glass_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _density = false;
  static const _fallback = LatLng(30.3753, 69.3451);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final location = context.watch<LocationProvider>();
    final steps = context.watch<StepProvider>();
    final user = context.watch<UserProvider>();
    final points = location.routePoints;
    final route = location.isTracking
        ? location.currentRoute
        : location.selectedRoute;
    final center = points.isNotEmpty
        ? points.last
        : location.currentPosition ?? _fallback;
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: points.isEmpty ? 5.2 : 15,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.strideup.stride_up',
              retinaMode: RetinaMode.isHighDensity(context),
            ),
            if (!_density && points.isNotEmpty) ...[
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 5,
                    gradientColors: [
                      colors.primaryContainer,
                      colors.secondaryFixed,
                    ],
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: points.first,
                    width: 18,
                    height: 18,
                    child: _marker(colors.primaryContainer),
                  ),
                  Marker(
                    point: points.last,
                    width: 22,
                    height: 22,
                    child: _marker(colors.secondaryFixed),
                  ),
                ],
              ),
            ],
            if (_density && location.heatPoints.isNotEmpty)
              CircleLayer(
                circles: location.heatPoints
                    .map(
                      (point) => CircleMarker(
                        point: point,
                        radius: 18,
                        useRadiusInMeter: true,
                        color: colors.primaryContainer.withValues(alpha: 0.22),
                        borderColor: colors.primaryContainer.withValues(
                          alpha: 0.35,
                        ),
                        borderStrokeWidth: 1,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                'Route',
                Icons.route,
                !_density,
                colors,
                () => setState(() => _density = false),
              ),
              _pill(
                'Recorded density',
                Icons.blur_on,
                _density,
                colors,
                () => setState(() => _density = true),
              ),
              _pill(
                'History (${location.savedRoutes.length})',
                Icons.history,
                false,
                colors,
                () => _showHistory(context, location, user),
              ),
            ],
          ),
        ),
        if (points.isEmpty)
          Center(
            child: GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(18),
              child: Text(
                location.savedRoutes.isEmpty
                    ? 'No recorded walks yet. Tap play to record one.'
                    : 'Choose a saved walk from History.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (location.error != null)
          Positioned(
            top: 72,
            left: 16,
            right: 16,
            child: Material(
              color: colors.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(location.error!),
              ),
            ),
          ),
        Positioned(
          right: 16,
          top: 112,
          child: GestureDetector(
            onTap: () async {
              await location.centerOnUser();
              if (location.currentPosition != null) {
                _mapController.move(location.currentPosition!, 16);
              }
            },
            child: _fab(Icons.my_location, colors),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 142,
          child: GestureDetector(
            onTap: () async {
              if (location.isTracking) {
                await location.stopTracking(finalSteps: steps.todaySteps);
              } else if (!user.locationTracking) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enable Location Tracking in Profile first.',
                      ),
                    ),
                  );
                }
              } else {
                await location.startTracking(initialSteps: steps.todaySteps);
              }
            },
            child: _fab(
              location.isTracking ? Icons.stop : Icons.play_arrow,
              colors,
              color: location.isTracking
                  ? colors.error
                  : colors.primaryContainer,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: _stats(route, user.useKilometers, colors),
        ),
      ],
    );
  }

  Widget _marker(Color color) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: [
        BoxShadow(color: color.withValues(alpha: .5), blurRadius: 10),
      ],
    ),
  );

  Widget _pill(
    String label,
    IconData icon,
    bool active,
    AppColors colors,
    VoidCallback tap,
  ) => GestureDetector(
    onTap: tap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          color: active
              ? colors.primaryContainer.withValues(alpha: .9)
              : colors.surface.withValues(alpha: .82),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _fab(IconData icon, AppColors colors, {Color? color}) => Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color ?? colors.surfaceContainerHigh,
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 12),
      ],
    ),
    child: Icon(icon, color: Colors.white),
  );

  Widget _stats(RouteData? route, bool km, AppColors colors) => GlassCard(
    borderRadius: 24,
    blur: 20,
    padding: const EdgeInsets.all(16),
    child: route == null
        ? const Text(
            'Distance, time, pace and steps will appear after recording starts.',
          )
        : Row(
            children: [
              Expanded(
                child: _metric(
                  'DISTANCE',
                  '${displayDistance(route.distanceKm, km).toStringAsFixed(2)} ${distanceUnit(km)}',
                ),
              ),
              Expanded(child: _metric('TIME', formatDuration(route.duration))),
              Expanded(
                child: _metric(
                  'PACE',
                  displayPace(route.duration, route.distanceKm, km),
                ),
              ),
              Expanded(
                child: _metric(
                  'STEPS',
                  route.stepsAvailable
                      ? formatNumber(route.steps)
                      : 'Unavailable',
                ),
              ),
            ],
          ),
  );

  Widget _metric(String label, String value) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: const TextStyle(fontSize: 9)),
      const SizedBox(height: 3),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    ],
  );

  void _showHistory(
    BuildContext context,
    LocationProvider location,
    UserProvider user,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Recorded walks',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (location.savedRoutes.isEmpty)
              const ListTile(title: Text('No routes recorded yet')),
            ...location.savedRoutes.map(
              (route) => ListTile(
                leading: const Icon(Icons.route),
                title: Text(formatDate(route.startTime)),
                subtitle: Text(
                  '${displayDistance(route.distanceKm, user.useKilometers).toStringAsFixed(2)} ${distanceUnit(user.useKilometers)} · ${formatDuration(route.duration)}${route.interrupted ? ' · interrupted' : ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => location.deleteRoute(route),
                ),
                onTap: () {
                  location.selectRoute(route);
                  Navigator.pop(context);
                  if (route.points.isNotEmpty) {
                    _mapController.move(route.points.last, 15);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
