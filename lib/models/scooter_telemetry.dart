// lib/models/scooter_telemetry.dart
import 'package:latlong2/latlong.dart';

class ScooterTelemetry {
  final String rideId;
  final String scooterId;
  final double odometerReading; // In meters from scooter
  final double batteryLevel; // 0.0 to 1.0
  final double estimatedRange; // In meters
  final bool isCharging;
  final bool isPaused;
  final double currentSpeed; // In km/h
  final double baseFare;
  final double distanceRate; // Per KM
  final double timeRate; // Per minute
  final DateTime startTime;
  final List<LatLng> routeCoordinates;
  final bool inGeofence;

  ScooterTelemetry({
    required this.rideId,
    required this.scooterId,
    required this.odometerReading,
    required this.batteryLevel,
    required this.estimatedRange,
    required this.isCharging,
    required this.isPaused,
    required this.currentSpeed,
    required this.baseFare,
    required this.distanceRate,
    required this.timeRate,
    required this.startTime,
    required this.routeCoordinates,
    required this.inGeofence,
  });

  factory ScooterTelemetry.fromJson(Map<String, dynamic> json) {
    return ScooterTelemetry(
      rideId: json['ride_id'],
      scooterId: json['scooter_id'],
      odometerReading: (json['odometer_reading'] as num).toDouble(),
      batteryLevel: (json['battery_level'] as num).toDouble(),
      estimatedRange: (json['estimated_range'] as num).toDouble(),
      isCharging: json['is_charging'],
      isPaused: json['is_paused'],
      currentSpeed: (json['current_speed'] as num).toDouble(),
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceRate: (json['distance_rate'] as num).toDouble(),
      timeRate: (json['time_rate'] as num).toDouble(),
      startTime: DateTime.parse(json['start_time']),
      routeCoordinates: (json['route_coordinates'] as List)
          .map((coord) => LatLng(coord['lat'], coord['lng']))
          .toList(),
      inGeofence: json['in_geofence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': rideId,
      'scooter_id': scooterId,
      'odometer_reading': odometerReading,
      'battery_level': batteryLevel,
      'estimated_range': estimatedRange,
      'is_charging': isCharging,
      'is_paused': isPaused,
      'current_speed': currentSpeed,
      'base_fare': baseFare,
      'distance_rate': distanceRate,
      'time_rate': timeRate,
      'start_time': startTime.toIso8601String(),
      'route_coordinates': routeCoordinates.map((coord) {
        return {'lat': coord.latitude, 'lng': coord.longitude};
      }).toList(),
      'in_geofence': inGeofence,
    };
  }
}