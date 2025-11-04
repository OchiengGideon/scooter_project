// lib/models/scooter_telemetry.dart
import 'package:latlong2/latlong.dart';

/// Represents real-time telemetry data from a scooter.
class ScooterTelemetry {
  final String rideId;
  final String scooterId;
  final double odometerReading; // Meters
  final double batteryLevel; // 0.0–1.0
  final double estimatedRange; // Meters
  final bool isCharging;
  final double currentSpeed; // km/h
  final double baseFare;
  final double distanceRate; // Per km
  final double timeRate; // Per min
  final DateTime startTime;
  final List<LatLng> routeCoordinates;
  final bool inGeofence; // Within booth zone
  final LatLng? nearestBooth; // Added context

  ScooterTelemetry({
    required this.rideId,
    required this.scooterId,
    required this.odometerReading,
    required this.batteryLevel,
    required this.estimatedRange,
    required this.isCharging,
    required this.currentSpeed,
    required this.baseFare,
    required this.distanceRate,
    required this.timeRate,
    required this.startTime,
    required this.routeCoordinates,
    required this.inGeofence,
    this.nearestBooth,
  });

  factory ScooterTelemetry.fromJson(Map<String, dynamic> json) {
    return ScooterTelemetry(
      rideId: json['ride_id'] ?? json['rideId'] ?? '',
      scooterId: json['scooter_id'] ?? json['scooterId'] ?? '',
      odometerReading:
      (json['odometer_reading'] as num?)?.toDouble() ?? 0.0,
      batteryLevel: (json['battery_level'] as num?)?.toDouble() ?? 0.0,
      estimatedRange: (json['estimated_range'] as num?)?.toDouble() ?? 0.0,
      isCharging: json['is_charging'] ?? json['isCharging'] ?? false,
      currentSpeed: (json['current_speed'] as num?)?.toDouble() ?? 0.0,
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? 0.0,
      distanceRate: (json['distance_rate'] as num?)?.toDouble() ?? 0.0,
      timeRate: (json['time_rate'] as num?)?.toDouble() ?? 0.0,
      startTime: DateTime.parse(json['start_time'] ?? json['startTime']),
      routeCoordinates: (json['route_coordinates'] as List? ??
          json['routeCoordinates'] as List? ??
          [])
          .map((coord) => LatLng(
          (coord['lat'] as num).toDouble(),
          (coord['lng'] as num).toDouble()))
          .toList(),
      inGeofence: json['in_geofence'] ?? json['inGeofence'] ?? true,
      nearestBooth: json['nearest_booth'] != null
          ? LatLng(
          (json['nearest_booth']['lat'] as num).toDouble(),
          (json['nearest_booth']['lng'] as num).toDouble())
          : null,
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
      'current_speed': currentSpeed,
      'base_fare': baseFare,
      'distance_rate': distanceRate,
      'time_rate': timeRate,
      'start_time': startTime.toIso8601String(),
      'route_coordinates': routeCoordinates
          .map((coord) => {'lat': coord.latitude, 'lng': coord.longitude})
          .toList(),
      'in_geofence': inGeofence,
      if (nearestBooth != null)
        'nearest_booth': {
          'lat': nearestBooth!.latitude,
          'lng': nearestBooth!.longitude,
        },
    };
  }
}
