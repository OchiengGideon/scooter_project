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
    this.routeCoordinates = const [],
    required this.currentBattery,
    required this.estimatedRange,
  });

  /// Calculate fare (no pause logic — single continuous ride)
  double get calculatedFare {
    final distanceKm = totalDistance / 1000.0;
    final timeMinutes = _calculateRideDuration().inMinutes.toDouble();
    return baseFare + (distanceKm * distanceRate) + (timeMinutes * timeRate);
  }

  Duration _calculateRideDuration() {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  // JSON serialization
  factory RideLiveData.fromJson(Map<String, dynamic> json) {
    return RideLiveData(
      rideId: json['ride_id'] ?? json['rideId'] ?? '',
      scooterId: json['scooter_id'] ?? json['scooterId'] ?? '',
      totalDistance: (json['total_distance'] as num?)?.toDouble() ??
          (json['totalDistance'] as num?)?.toDouble() ??
          0.0,
      baseFare: (json['base_fare'] as num?)?.toDouble() ??
          (json['baseFare'] as num?)?.toDouble() ??
          0.0,
      distanceRate: (json['distance_rate'] as num?)?.toDouble() ??
          (json['distanceRate'] as num?)?.toDouble() ??
          0.0,
      timeRate: (json['time_rate'] as num?)?.toDouble() ??
          (json['timeRate'] as num?)?.toDouble() ??
          0.0,
      startTime: DateTime.parse(json['start_time'] ?? json['startTime']),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      routeCoordinates: (json['route_coordinates'] as List? ??
          json['routeCoordinates'] as List? ??
          [])
          .map((coord) {
        final lat = (coord['lat'] as num).toDouble();
        final lng = (coord['lng'] as num).toDouble();
        return LatLng(lat, lng);
      })
          .toList(),
      currentBattery:
      (json['current_battery'] as num?)?.toDouble() ?? 0.0,
      estimatedRange:
      (json['estimated_range'] as num?)?.toDouble() ?? 0.0,
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
      'route_coordinates': routeCoordinates
          .map((coord) => {'lat': coord.latitude, 'lng': coord.longitude})
          .toList(),
      'current_battery': currentBattery,
      'estimated_range': estimatedRange,
    };
  }

  @override
  String toString() =>
      'RideLiveData(rideId: $rideId, scooterId: $scooterId, distance: $totalDistance m)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RideLiveData &&
              runtimeType == other.runtimeType &&
              rideId == other.rideId;

  @override
  int get hashCode => rideId.hashCode;
}
