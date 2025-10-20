// lib/repositories/ride_repository.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart';
import '../models/ride_live_data.dart';
import '../models/scooter_telemetry.dart';
import '../services/api_client.dart';
import '../services/location_service.dart';

class RideException implements Exception {
  final String message;
  RideException(this.message);

  @override
  String toString() => 'RideException: $message';
}

class RideRepository {
  final ApiClient _apiClient;
  final LocationService _locationService;
  final StreamController<RideLiveData> _rideStreamController =
  StreamController<RideLiveData>.broadcast();
  WebSocketChannel? _telemetryChannel;
  StreamSubscription<LatLng>? _locationSubscription;
  List<LatLng> _currentRoute = [];

  RideRepository(this._apiClient, this._locationService);

  // Stream for real-time ride updates from scooter
  Stream<RideLiveData> get liveRideData => _rideStreamController.stream;

  // Start ride and establish connection to scooter
  Future<RideLiveData> startRide(String scooterId, String qrCode) async {
    try {
      final currentLocation = await _locationService.getCurrentLocation();

      final response = await _apiClient.post('/rides/start', {
        'scooter_id': scooterId,
        'qr_code': qrCode,
        'start_location': {
          'lat': currentLocation.latitude,
          'lng': currentLocation.longitude,
        },
        'timestamp': DateTime.now().toIso8601String(),
      });

      final rideData = RideLiveData.fromJson(response.data['ride']);
      _currentRoute = [currentLocation];

      // Start listening to scooter telemetry
      _startScooterTelemetryStream(rideData.rideId);

      // Start tracking user location
      _startLocationTracking();

      return rideData;
    } catch (e) {
      throw RideException('Failed to start ride: ${e.toString()}');
    }
  }

  // Stop ride and finalize calculations
  Future<Map<String, dynamic>> stopRide(String rideId, LatLng endLocation) async {
    try {
      _currentRoute.add(endLocation);

      final response = await _apiClient.post('/rides/stop', {
        'ride_id': rideId,
        'end_location': {
          'lat': endLocation.latitude,
          'lng': endLocation.longitude,
        },
        'route_coordinates': _currentRoute.map((coord) {
          return {'lat': coord.latitude, 'lng': coord.longitude};
        }).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      _stopScooterTelemetryStream();
      _stopLocationTracking();
      _currentRoute.clear();

      return response.data;
    } catch (e) {
      throw RideException('Failed to stop ride: ${e.toString()}');
    }
  }

  // Pause/resume ride
  Future<void> toggleRidePause(String rideId, bool pause) async {
    try {
      await _apiClient.post('/rides/${pause ? 'pause' : 'resume'}', {
        'ride_id': rideId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw RideException('Failed to ${pause ? 'pause' : 'resume'} ride: ${e.toString()}');
    }
  }

  // Get ride history for user
  Future<List<RideLiveData>> getRideHistory() async {
    try {
      final response = await _apiClient.get('/rides/history');

      return (response.data['rides'] as List)
          .map((rideJson) => RideLiveData.fromJson(rideJson))
          .toList();
    } catch (e) {
      throw RideException('Failed to fetch ride history: ${e.toString()}');
    }
  }

  // Get specific ride details
  Future<RideLiveData> getRideDetails(String rideId) async {
    try {
      final response = await _apiClient.get('/rides/$rideId');
      return RideLiveData.fromJson(response.data['ride']);
    } catch (e) {
      throw RideException('Failed to fetch ride details: ${e.toString()}');
    }
  }

  // Private method to handle scooter telemetry stream
  void _startScooterTelemetryStream(String rideId) {
    try {
      // In production, use your actual WebSocket endpoint
      const useMockWebSocket = true; // Set to false for real backend

      if (useMockWebSocket) {
        _startMockTelemetryStream(rideId);
      } else {
        _telemetryChannel = IOWebSocketChannel.connect(
          'wss://api.yourscooterapp.com/rides/$rideId/telemetry',
        );

        _telemetryChannel!.stream.listen(
              (data) {
            try {
              final telemetry = ScooterTelemetry.fromJson(json.decode(data));
              _updateRideData(telemetry);
            } catch (e) {
              debugPrint('Error parsing telemetry data: $e');
            }
          },
          onError: (error) {
            _handleTelemetryError(error);
          },
          onDone: () {
            debugPrint('Telemetry stream closed');
          },
        );
      }
    } catch (e) {
      _handleTelemetryError(e);
    }
  }

  // Mock WebSocket for development
  void _startMockTelemetryStream(String rideId) {
    debugPrint('Starting mock telemetry stream for ride: $rideId');

    Timer.periodic(Duration(seconds: 2), (timer) {
      if (_telemetryChannel != null && !_rideStreamController.isClosed) {
        final mockTelemetry = ScooterTelemetry(
          rideId: rideId,
          scooterId: 'scooter_${rideId.substring(0, 8)}',
          odometerReading: _currentRoute.isNotEmpty
              ? _locationService.calculateTotalDistance(_currentRoute)
              : 0.0,
          batteryLevel: 0.85 - (timer.tick * 0.001), // Simulate battery drain
          estimatedRange: 15000 - (timer.tick * 10), // Simulate range decrease
          isCharging: false,
          isPaused: false,
          currentSpeed: 12.5 + (DateTime.now().second % 10).toDouble(), // Varying speed
          baseFare: 1.50,
          distanceRate: 0.25,
          timeRate: 0.15,
          startTime: DateTime.now().subtract(Duration(seconds: timer.tick * 2)),
          routeCoordinates: _currentRoute,
          inGeofence: true,
        );

        _updateRideData(mockTelemetry);
      }
    });
  }

  void _updateRideData(ScooterTelemetry telemetry) {
    // Update ride data with scooter transmission
    final updatedRide = RideLiveData(
      rideId: telemetry.rideId,
      scooterId: telemetry.scooterId,
      totalDistance: telemetry.odometerReading, // Direct from scooter
      baseFare: telemetry.baseFare,
      distanceRate: telemetry.distanceRate,
      timeRate: telemetry.timeRate,
      startTime: telemetry.startTime,
      currentBattery: telemetry.batteryLevel,
      estimatedRange: telemetry.estimatedRange,
      routeCoordinates: telemetry.routeCoordinates,
      isPaused: telemetry.isPaused,
    );

    if (!_rideStreamController.isClosed) {
      _rideStreamController.add(updatedRide);
    }
  }

  // Start tracking user location
  void _startLocationTracking() {
    _locationSubscription = _locationService.locationStream.listen(
          (location) {
        _currentRoute.add(location);
        debugPrint('Location updated: ${location.latitude}, ${location.longitude}');
      },
      onError: (error) {
        debugPrint('Location tracking error: $error');
      },
    );
  }

  void _stopScooterTelemetryStream() {
    _telemetryChannel?.sink.close();
    _telemetryChannel = null;
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void _handleTelemetryError(dynamic error) {
    debugPrint('Scooter telemetry error: $error');
    if (!_rideStreamController.isClosed) {
      _rideStreamController.addError(RideException('Telemetry connection lost'));
    }
  }

  // Clean up resources
  void dispose() {
    _stopScooterTelemetryStream();
    _stopLocationTracking();
    if (!_rideStreamController.isClosed) {
      _rideStreamController.close();
    }
  }
}