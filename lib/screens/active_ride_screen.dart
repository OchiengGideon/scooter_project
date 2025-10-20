// lib/screens/active_ride_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import '../models/ride_live_data.dart';
import '../repositories/ride_repository.dart';
import '../services/location_service.dart';

class ActiveRideScreen extends StatefulWidget {
  final String scooterId;
  final String qrCode;

  const ActiveRideScreen({
    Key? key,
    required this.scooterId,
    required this.qrCode,
  }) : super(key: key);

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  final RideRepository _rideRepository = GetIt.instance<RideRepository>();
  final LocationService _locationService = GetIt.instance<LocationService>();

  StreamSubscription<RideLiveData>? _rideSubscription;
  RideLiveData? _currentRide;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showStopConfirmation = false;
  Timer? _updateTimer;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _startRide();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _rideSubscription?.cancel();
    _updateTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentRide != null && mounted) {
        setState(() {
          // Trigger UI update for time-based calculations
        });
      }
    });
  }

  Future<void> _startRide() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Start ride and connect to scooter telemetry
      final rideData = await _rideRepository.startRide(
        widget.scooterId,
        widget.qrCode,
      );

      // Listen to real-time updates from scooter
      _rideSubscription = _rideRepository.liveRideData.listen(
            (rideData) {
          if (mounted) {
            setState(() {
              _currentRide = rideData;
              _isLoading = false;
            });
            // Update map center if we have coordinates
            if (rideData.routeCoordinates.isNotEmpty) {
              _mapController.move(
                rideData.routeCoordinates.last,
                15.0,
              );
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Connection to scooter lost: $error';
              _isLoading = false;
            });
          }
        },
      );

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to start ride: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _stopRide() async {
    try {
      setState(() { _isLoading = true; });

      final currentLocation = await _locationService.getCurrentLocation();
      final endLocation = LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      );

      final receipt = await _rideRepository.stopRide(
        _currentRide!.rideId,
        endLocation,
      );

      if (mounted) {
        // Navigate to ride summary screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RideSummaryScreen(receipt: receipt),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to stop ride: ${e.toString()}';
          _isLoading = false;
          _showStopConfirmation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop ride: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePause() async {
    if (_currentRide == null) return;

    try {
      await _rideRepository.toggleRidePause(
        _currentRide!.rideId,
        !_currentRide!.isPaused,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_currentRide!.isPaused ? 'resume' : 'pause'} ride'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Ride'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_currentRide != null)
            IconButton(
              icon: Icon(_currentRide!.isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: _togglePause,
              tooltip: _currentRide!.isPaused ? 'Resume Ride' : 'Pause Ride',
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to scooter...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Ride Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _startRide,
                    child: Text('Retry Connection'),
                  ),
                  SizedBox(width: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel Ride'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_currentRide == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.electric_scooter, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active ride data'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ride Overview Card
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRideMetricRow(
                    'Distance',
                    '${(_currentRide!.totalDistance / 1000).toStringAsFixed(2)} km',
                    Icons.directions_bike,
                  ),
                  SizedBox(height: 12),
                  _buildRideMetricRow(
                    'Current Fare',
                    '\$${_currentRide!.fareWithDeductions.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                  SizedBox(height: 12),
                  _buildRideMetricRow(
                    'Ride Time',
                    _formatDuration(_calculateRideDuration()),
                    Icons.timer,
                  ),
                  SizedBox(height: 12),
                  _buildRideMetricRow(
                    'Battery',
                    '${(_currentRide!.currentBattery * 100).toStringAsFixed(0)}%',
                    Icons.battery_std,
                    valueColor: _getBatteryColor(_currentRide!.currentBattery),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Scooter Status Card
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scooter Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.electric_scooter, size: 20, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text('ID: ${_currentRide!.scooterId}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.speed, size: 20, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text('Range: ${(_currentRide!.estimatedRange / 1000).toStringAsFixed(1)} km remaining'),
                    ],
                  ),
                  if (_currentRide!.isPaused) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pause, size: 16, color: Colors.orange[800]),
                          SizedBox(width: 6),
                          Text(
                            'RIDE PAUSED',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Map Preview
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Map',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _currentRide!.routeCoordinates.isNotEmpty
                        ? _buildMapPreview()
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 8),
                          Text(
                            'Waiting for route data...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideMetricRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: valueColor ?? Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    final routeCoordinates = _currentRide!.routeCoordinates;
    final center = routeCoordinates.isNotEmpty ? routeCoordinates.last : LatLng(0, 0);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: center,
        zoom: 15.0,
        interactiveFlags: InteractiveFlag.none,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.scooter_app',
        ),
        if (routeCoordinates.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routeCoordinates,
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 4.0,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (routeCoordinates.isNotEmpty)
              Marker(
                point: routeCoordinates.first,
                width: 20,
                height: 20,
                child: Container(
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            if (routeCoordinates.isNotEmpty)
              Marker(
                point: routeCoordinates.last,
                width: 20,
                height: 20,
                child: Container(
                  child: Icon(Icons.location_on, color: Colors.white, size: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    if (_isLoading || _currentRide == null) {
      return SizedBox();
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _showStopConfirmation
                  ? _buildStopConfirmation()
                  : ElevatedButton.icon(
                onPressed: () {
                  setState(() { _showStopConfirmation = true; });
                },
                icon: Icon(Icons.stop, size: 20),
                label: Text(
                  'END RIDE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopConfirmation() {
    return Column(
      children: [
        Text(
          'End this ride?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() { _showStopConfirmation = false; });
                },
                child: Text('CANCEL'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _stopRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text('END RIDE'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBatteryColor(double batteryLevel) {
    if (batteryLevel > 0.5) return Colors.green;
    if (batteryLevel > 0.2) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Calculate ride duration using the model's private method
  Duration _calculateRideDuration() {
    // Since _calculateRideDuration is private in RideLiveData, we'll calculate it here
    final end = _currentRide!.endTime ?? DateTime.now();
    return end.difference(_currentRide!.startTime);
  }
}

// Ride Summary Screen
class RideSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> receipt;

  const RideSummaryScreen({Key? key, required this.receipt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalFare = receipt['total_fare']?.toStringAsFixed(2) ?? '0.00';
    final String distance;
    if (receipt['total_distance'] != null) {
      distance = '${((receipt['total_distance'] as num) / 1000).toStringAsFixed(2)} km';
    } else {
      distance = '0.00 km';
    }
    final duration = receipt['duration_minutes'] != null
        ? '${receipt['duration_minutes']} min'
        : '0 min';

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Summary'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Ride Completed!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Thank you for riding with us',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Ride Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Total Fare',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$$totalFare',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 24),
                    Divider(),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Distance', style: TextStyle(color: Colors.grey[600])),
                        Text(distance, style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duration', style: TextStyle(color: Colors.grey[600])),
                        Text(duration, style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Scooter ID', style: TextStyle(color: Colors.grey[600])),
                        Text(receipt['scooter_id']?.toString() ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Spacer(),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}