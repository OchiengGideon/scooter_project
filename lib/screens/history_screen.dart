import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/trip.dart';
import '../models/ride_receipt.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Trip> _completedRides = [];
  List<Trip> _cancelledRides = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRides() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final allRides = userProvider.user.tripHistory;

    _completedRides = allRides.where((trip) => trip.endTime != null).toList();
    _cancelledRides = allRides.where((trip) => trip.cost == 0 && trip.endTime != null).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Rides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(Trip trip, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideDetailScreen(trip: trip),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(trip.startTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: trip.cost == 0 ? Colors.orange[100] : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trip.cost == 0 ? 'CANCELLED' : 'COMPLETED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: trip.cost == 0 ? Colors.orange[800] : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scooter ID',
                        style: TextStyle(
                          color: AppColors.textDark.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        trip.scooterId,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distance',
                        style: TextStyle(
                          color: AppColors.textDark.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${trip.distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                          color: AppColors.textDark.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDuration(trip.duration),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Fare',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    trip.cost == 0 ? 'No Charge' : '\$${trip.cost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: trip.cost == 0 ? Colors.grey : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final userProvider = Provider.of<UserProvider>(context);
    final completedRides = _completedRides.where((trip) => trip.cost > 0).toList();

    if (completedRides.isEmpty) {
      return SizedBox();
    }

    final totalRides = completedRides.length;
    final totalDistance = completedRides.fold(0.0, (sum, trip) => sum + trip.distance);
    final totalSpent = completedRides.fold(0.0, (sum, trip) => sum + trip.cost);
    final averageCost = totalSpent / totalRides;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ride Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Rides', totalRides.toString()),
                _buildStatItem('Total Distance', '${totalDistance.toStringAsFixed(1)} km'),
                _buildStatItem('Total Spent', '\$${totalSpent.toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Text(
              'Average per ride: \$${averageCost.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppColors.textDark.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textDark.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Completed (${_completedRides.length})'),
            Tab(text: 'Cancelled (${_cancelledRides.length})'),
          ],
          indicatorColor: Colors.white,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Completed Rides Tab
          _completedRides.isEmpty
              ? _buildEmptyState('Your completed rides will appear here')
              : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatisticsCard(),
                SizedBox(height: 16),
                ..._completedRides.map((trip) => _buildRideCard(trip, context)),
              ],
            ),
          ),

          // Cancelled Rides Tab
          _cancelledRides.isEmpty
              ? _buildEmptyState('Your cancelled rides will appear here')
              : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ..._cancelledRides.map((trip) => _buildRideCard(trip, context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Ride Detail Screen
class RideDetailScreen extends StatelessWidget {
  final Trip trip;

  const RideDetailScreen({super.key, required this.trip});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildMapPreview(List<LatLng>? routeCoordinates) {
    final coordinates = routeCoordinates ?? [];
    final center = coordinates.isNotEmpty ? coordinates[coordinates.length ~/ 2] : LatLng(0, 0);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: coordinates.isNotEmpty
          ? FlutterMap(
        options: MapOptions(
          center: center,
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.none,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.scooter_app',
          ),
          if (coordinates.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: coordinates,
                  color: AppColors.primary,
                  strokeWidth: 4.0,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              if (coordinates.isNotEmpty)
                Marker(
                  point: coordinates.first,
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
              if (coordinates.isNotEmpty)
                Marker(
                  point: coordinates.last,
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
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'No route data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'RIDE RECEIPT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Ride Information
            _buildReceiptRow('Scooter ID', trip.scooterId),
            _buildReceiptRow('Date', _formatDate(trip.startTime)),
            _buildReceiptRow('Start Time', _formatTime(trip.startTime)),
            if (trip.endTime != null)
              _buildReceiptRow('End Time', _formatTime(trip.endTime!)),
            _buildReceiptRow('Duration', _formatDuration(trip.duration)),
            _buildReceiptRow('Distance', '${trip.distance.toStringAsFixed(2)} km'),

            Divider(),
            SizedBox(height: 8),

            // Fare Breakdown
            _buildReceiptRow('Base Fare', '\$${trip.cost * 0.3}', isAmount: true),
            _buildReceiptRow('Distance Fare', '\$${trip.cost * 0.5}', isAmount: true),
            _buildReceiptRow('Time Fare', '\$${trip.cost * 0.2}', isAmount: true),

            Divider(),
            SizedBox(height: 8),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '\$${trip.cost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textDark.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.w500 : FontWeight.normal,
              color: isAmount ? AppColors.textDark : AppColors.textDark.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share ride details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReceiptCard(),
            SizedBox(height: 20),
            Text(
              'Route Map',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12),
            _buildMapPreview([]), // Empty for now, would use actual route data
            SizedBox(height: 20),
            if (trip.cost > 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Report issue with ride
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Issue reporting coming soon!')),
                    );
                  },
                  icon: Icon(Icons.report_problem),
                  label: Text('Report an Issue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
}