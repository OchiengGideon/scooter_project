// lib/services/location_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Handles all GPS-related functionality for rides.
class LocationService {
  final Distance _distance = const Distance();
  final StreamController<LatLng> _locationStreamController =
  StreamController<LatLng>.broadcast();

  StreamSubscription<Position>? _positionStreamSubscription;

  // Simulated or known scooter booth coordinates (example for Kenya)
  final List<LatLng> _boothLocations = const [
    LatLng(-1.286389, 36.817223), // Nairobi CBD Booth
    LatLng(-1.2921, 36.8219), // Kenyatta Ave Booth
    LatLng(-1.3009, 36.7993), // Westlands Booth
    LatLng(-1.3116, 36.8445), // Industrial Area Booth
  ];

  bool _serviceRunning = false;

  Stream<LatLng> get locationStream => _locationStreamController.stream;

  /// Requests location permissions and returns whether granted.
  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return false;
    }

    return true;
  }

  /// Gets the current device location.
  Future<LatLng> getCurrentLocation() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      throw Exception('Location permission not granted.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  /// Starts continuous location tracking.
  Future<void> startTracking() async {
    if (_serviceRunning) return;

    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      throw Exception('Location permission not granted.');
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5, // meters
          ),
        ).listen((Position position) {
          final location = LatLng(position.latitude, position.longitude);
          _locationStreamController.add(location);
        });

    _serviceRunning = true;
  }

  /// Stops continuous location tracking.
  Future<void> stopTracking() async {
    await _positionStreamSubscription?.cancel();
    _serviceRunning = false;
  }

  /// Calculates the straight-line distance between two coordinates in meters.
  double calculateDistance(LatLng start, LatLng end) {
    return _distance(start, end);
  }

  /// Calculates the total distance of a multi-point route in meters.
  double calculateTotalDistance(List<LatLng> route) {
    if (route.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      total += _distance(route[i], route[i + 1]);
    }
    return total;
  }

  /// Finds the nearest booth to the current location.
  LatLng? getNearestBooth(LatLng location, {double maxDistanceMeters = 100.0}) {
    LatLng? nearest;
    double minDistance = double.infinity;

    for (final booth in _boothLocations) {
      final distance = calculateDistance(location, booth);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = booth;
      }
    }

    return (minDistance <= maxDistanceMeters) ? nearest : null;
  }

  /// Checks if the location is within range of a valid booth.
  bool isWithinBooth(LatLng location, {double threshold = 100.0}) {
    return getNearestBooth(location, maxDistanceMeters: threshold) != null;
  }

  /// Returns all booth locations (for map display or validation).
  List<LatLng> getAllBooths() => _boothLocations;

  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationStreamController.close();
  }
}
