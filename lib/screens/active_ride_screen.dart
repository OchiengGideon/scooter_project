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
  final MapController _mapController = MapController();

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
    super.dispose();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentRide != null && mounted) {
        setState(() {}); // update time/fare dynamically
      }
    });
  }

  Future<void> _startRide() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final rideData = await _rideRepository.startRide(
        widget.scooterId,
        widget.qrCode,
      );

      _rideSubscription = _rideRepository.liveRideData.listen(
            (rideData) {
          if (mounted) {
            setState(() {
              _currentRide = rideData;
              _isLoading = false;
            });

            if (rideData.routeCoordinates.isNotEmpty) {
              _mapController.move(rideData.routeCoordinates.last, 15.0);
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
          _errorMessage = 'Failed to start ride: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _stopRide() async {
    if (_currentRide == null) return;

    try {
      setState(() => _isLoading = true);

      final currentLocation = await _locationService.getCurrentLocation();
      final endLocation = LatLng(currentLocation.latitude, currentLocation.longitude);

      final receipt = await _rideRepository.stopRide(
        _currentRide!.rideId,
        endLocation,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RideSummaryScreen(receipt: receipt)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to stop ride: $e';
          _isLoading = false;
          _showStopConfirmation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop ride: $e'),
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

  // ---------------- UI BUILDING ----------------

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
      return _buildErrorScreen();
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRideOverviewCard(),
          const SizedBox(height: 16),
          _buildScooterStatusCard(),
          const SizedBox(height: 16),
          _buildMapCard(),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Ride Error',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.red)),
          const SizedBox(height: 16),
          Text(_errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _startRide, child: const Text('Retry')),
              const SizedBox(width: 16),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildRideOverviewCard() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRideMetricRow('Distance', '${(_currentRide!.totalDistance / 1000).toStringAsFixed(2)} km', Icons.route),
          const SizedBox(height: 12),
          _buildRideMetricRow('Fare', '\$${_currentRide!.fareWithDeductions.toStringAsFixed(2)}', Icons.attach_money),
          const SizedBox(height: 12),
          _buildRideMetricRow('Duration', _formatDuration(_calculateRideDuration()), Icons.timer),
          const SizedBox(height: 12),
          _buildRideMetricRow(
            'Battery',
            '${(_currentRide!.currentBattery * 100).toStringAsFixed(0)}%',
            Icons.battery_full,
            valueColor: _getBatteryColor(_currentRide!.currentBattery),
          ),
        ],
      ),
    ),
  );

  Widget _buildRideMetricRow(
      String label,
      String value,
      IconData icon, {
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: valueColor ?? Colors.black,
              )),
        ],
      ),
    );
  }

  Widget _buildScooterStatusCard() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Scooter Status', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.confirmation_number_outlined, size: 18),
          const SizedBox(width: 8),
          Text('ID: ${_currentRide!.scooterId}'),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.speed, size: 18),
          const SizedBox(width: 8),
          Text('Range: ${(_currentRide!.estimatedRange / 1000).toStringAsFixed(1)} km'),
        ]),
        if (_currentRide!.isPaused) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.pause, size: 16, color: Colors.orange),
              SizedBox(width: 6),
              Text('RIDE PAUSED', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]
      ]),
    ),
  );

  Widget _buildMapCard() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Route Map', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
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
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.map, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('Waiting for route data...', style: TextStyle(color: Colors.grey[600])),
            ]),
          ),
        ),
      ]),
    ),
  );

  Widget _buildMapPreview() {
    final route = _currentRide!.routeCoordinates;
    final center = route.isNotEmpty ? route.last : const LatLng(0, 0);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(center: center, zoom: 15.0, interactiveFlags: InteractiveFlag.none),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.scooter_app',
        ),
        if (route.length > 1)
          PolylineLayer(polylines: [Polyline(points: route, color: Theme.of(context).colorScheme.primary, strokeWidth: 4)]),
        MarkerLayer(markers: [
          Marker(point: route.first, child: _buildMarker(Icons.play_arrow, Colors.green), width: 20, height: 20),
          Marker(point: route.last, child: _buildMarker(Icons.location_on, Colors.red), width: 20, height: 20),
        ]),
      ],
    );
  }

  Widget _buildMarker(IconData icon, Color color) => Container(
    decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
    child: Icon(icon, color: Colors.white, size: 12),
  );

  Widget _buildBottomControls() {
    if (_isLoading || _currentRide == null) return const SizedBox();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _showStopConfirmation ? _buildStopConfirmation() : _buildStopRideButton(),
      ),
    );
  }

  Widget _buildStopRideButton() => ElevatedButton.icon(
    onPressed: () => setState(() => _showStopConfirmation = true),
    icon: const Icon(Icons.stop, size: 20),
    label: const Text('END RIDE', style: TextStyle(fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  Widget _buildStopConfirmation() => Column(
    children: [
      Text('End this ride?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _showStopConfirmation = false),
            child: const Text('CANCEL'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _stopRide,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('END RIDE'),
          ),
        ),
      ]),
    ],
  );

  // ---------- HELPERS ----------
  Color _getBatteryColor(double batteryLevel) {
    if (batteryLevel > 0.5) return Colors.green;
    if (batteryLevel > 0.2) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Duration _calculateRideDuration() {
    final end = _currentRide!.endTime ?? DateTime.now();
    return end.difference(_currentRide!.startTime);
  }
}

// ---------------- RIDE SUMMARY SCREEN ----------------

class RideSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> receipt;
  const RideSummaryScreen({Key? key, required this.receipt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalFare = (receipt['total_fare'] is num)
        ? (receipt['total_fare'] as num).toStringAsFixed(2)
        : '0.00';
    final distance = (receipt['total_distance'] is num)
        ? '${((receipt['total_distance'] as num) / 1000).toStringAsFixed(2)} km'
        : '0.00 km';
    final duration = receipt['duration_minutes'] != null
        ? '${receipt['duration_minutes']} min'
        : '0 min';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Summary'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Column(children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              Text('Ride Completed!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Thank you for riding with us',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Text('Total Fare', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('\$$totalFare',
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _summaryRow('Distance', distance),
                const SizedBox(height: 12),
                _summaryRow('Duration', duration),
                const SizedBox(height: 12),
                _summaryRow('Scooter ID', receipt['scooter_id']?.toString() ?? 'Unknown'),
              ]),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ],
  );
}
