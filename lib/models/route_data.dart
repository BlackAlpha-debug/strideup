import 'package:latlong2/latlong.dart';

class RouteData {
  final List<LatLng> points;
  final double distanceKm;
  final Duration duration;
  final int steps;
  final DateTime startTime;
  final bool interrupted;
  final bool stepsAvailable;

  const RouteData({
    required this.points,
    required this.distanceKm,
    required this.duration,
    required this.steps,
    required this.startTime,
    this.interrupted = false,
    this.stepsAvailable = true,
  });

  String get id => startTime.microsecondsSinceEpoch.toString();
  Map<String, dynamic> toJson() => {
    'points': points.map((p) => [p.latitude, p.longitude]).toList(),
    'distanceKm': distanceKm,
    'durationMs': duration.inMilliseconds,
    'steps': steps,
    'startTime': startTime.toIso8601String(),
    'interrupted': interrupted,
    'stepsAvailable': stepsAvailable,
  };
  factory RouteData.fromJson(
    Map<String, dynamic> json, {
    bool recovered = false,
  }) => RouteData(
    points: (json['points'] as List)
        .map((p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
        .toList(),
    distanceKm: (json['distanceKm'] as num).toDouble(),
    duration: Duration(milliseconds: (json['durationMs'] as num).toInt()),
    steps: (json['steps'] as num).toInt(),
    startTime: DateTime.parse(json['startTime'] as String),
    interrupted: recovered || json['interrupted'] == true,
    stepsAvailable: json['stepsAvailable'] != false,
  );

  String get formattedPace {
    if (distanceKm <= 0) return "--'--\"";
    final secondsPerKm = duration.inSeconds / distanceKm;
    final minutes = (secondsPerKm / 60).floor();
    final seconds = (secondsPerKm % 60).floor();
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }
}
