// lib/services/location_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;
  StreamSubscription<Position>? _positionStream;
  final StreamController<LatLng> _locationController = StreamController<LatLng>.broadcast();

  Stream<LatLng> get locationStream => _locationController.stream;

  // Check and request location permissions
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await _geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location once
  Future<LatLng> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      // Check if location service is enabled
      bool serviceEnabled = await _geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      final position = await _geolocator.getCurrentPosition(
        // For newer versions, use locationSettings instead of desiredAccuracy
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0, // Get every update
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      rethrow;
    }
  }

  // Start continuous location updates
  Future<void> startLocationUpdates() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      // Check if location service is enabled
      bool serviceEnabled = await _geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      _positionStream = _geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 10, // Update every 10 meters
          timeLimit: null, // No time limit
        ),
      ).listen(
            (Position position) {
          final location = LatLng(position.latitude, position.longitude);
          _locationController.add(location);
          debugPrint('Location update: ${position.latitude}, ${position.longitude}');
        },
        onError: (error) {
          debugPrint('Location stream error: $error');
          _locationController.addError(error);
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Error starting location updates: $e');
      rethrow;
    }
  }

  // Get last known position
  Future<LatLng?> getLastKnownPosition() async {
    try {
      final Position? position = await _geolocator.getLastKnownPosition();
      if (position != null) {
        return LatLng(position.latitude, position.longitude);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }

  // Calculate distance between two points in meters
  double calculateDistance(LatLng start, LatLng end) {
    return _geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Calculate total distance from a list of points
  double calculateTotalDistance(List<LatLng> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < route.length; i++) {
      totalDistance += calculateDistance(route[i - 1], route[i]);
    }

    return totalDistance;
  }

  // Calculate bearing between two points
  double calculateBearing(LatLng start, LatLng end) {
    return _geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await _geolocator.isLocationServiceEnabled();
  }

  // Open location settings
  Future<bool> openLocationSettings() async {
    return await _geolocator.openLocationSettings();
  }

  // Open app settings for permission management
  Future<bool> openAppSettings() async {
    return await _geolocator.openAppSettings();
  }

  // Get location accuracy status
  Future<LocationAccuracyStatus> getAccuracyStatus() async {
    return await _geolocator.getLocationAccuracy();
  }

  // Request temporary elevated accuracy (for Android)
  Future<LocationAccuracyStatus> requestTemporaryFullAccuracy({
    required String purposeKey,
  }) async {
    return await _geolocator.requestTemporaryFullAccuracy(
      purposeKey: purposeKey,
    );
  }

  // Stop location updates
  void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
    debugPrint('Location updates stopped');
  }

  // Check if location updates are active
  bool get isTrackingLocation => _positionStream != null;

  // Clean up
  void dispose() {
    stopLocationUpdates();
    if (!_locationController.isClosed) {
      _locationController.close();
    }
    debugPrint('LocationService disposed');
  }
}