// lib/models/ride_live_data.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RideLiveData {
  final String rideId;
  final String scooterId;
  final double totalDistance; // From scooter odometer in meters
  final double baseFare;
  final double distanceRate;
  final double timeRate;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isPaused;
  final List<LatLng> routeCoordinates;
  final double currentBattery;
  final double estimatedRange;

  const RideLiveData({
    required this.rideId,
    required this.scooterId,
    required this.totalDistance,
    required this.baseFare,
    required this.distanceRate,
    required this.timeRate,
    required this.startTime,
    this.endTime,
    this.isPaused = false,
    this.routeCoordinates = const [],
    required this.currentBattery,
    required this.estimatedRange,
  });

  // Calculate fare with deductions
  double get calculatedFare {
    double distanceKm = totalDistance / 1000; // Convert to KM
    double timeMinutes = _calculateRideDuration().inMinutes.toDouble();

    return baseFare + (distanceKm * distanceRate) + (timeMinutes * timeRate);
  }

  Duration _calculateRideDuration() {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  // Apply deductions for pauses, boundaries, etc.
  double get fareWithDeductions {
    double baseFare = calculatedFare;

    // Deduction for ride pauses
    if (isPaused) {
      baseFare -= _calculatePauseDeduction();
    }

    // Deduction for out-of-bounds riding
    baseFare -= _calculateBoundaryDeduction();

    // Ensure fare doesn't go negative
    return baseFare > 0 ? baseFare : 0;
  }

  double _calculatePauseDeduction() {
    // Implement pause deduction logic
    return 0.0; // Placeholder
  }

  double _calculateBoundaryDeduction() {
    // Implement boundary violation deduction
    return 0.0; // Placeholder
  }

  // JSON serialization
  factory RideLiveData.fromJson(Map<String, dynamic> json) {
    return RideLiveData(
      rideId: json['ride_id'],
      scooterId: json['scooter_id'],
      totalDistance: (json['total_distance'] as num).toDouble(),
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceRate: (json['distance_rate'] as num).toDouble(),
      timeRate: (json['time_rate'] as num).toDouble(),
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      isPaused: json['is_paused'] ?? false,
      routeCoordinates: (json['route_coordinates'] as List? ?? []).map((coord) {
        return LatLng(coord['lat'], coord['lng']);
      }).toList(),
      currentBattery: (json['current_battery'] as num).toDouble(),
      estimatedRange: (json['estimated_range'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': rideId,
      'scooter_id': scooterId,
      'total_distance': totalDistance,
      'base_fare': baseFare,
      'distance_rate': distanceRate,
      'time_rate': timeRate,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_paused': isPaused,
      'route_coordinates': routeCoordinates.map((coord) {
        return {'lat': coord.latitude, 'lng': coord.longitude};
      }).toList(),
      'current_battery': currentBattery,
      'estimated_range': estimatedRange,
    };
  }
}