import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class ActiveRideScreen extends StatefulWidget {
  @override
  _ActiveRideScreenState createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  late DateTime _startTime;
  Duration _rideDuration = Duration.zero;
  double _distance = 0.0;
  double _currentFare = 0.0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
    _startDistanceTracking();
  }

  void _startTimer() {
    // Update ride duration every second
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _rideDuration = DateTime.now().difference(_startTime);
          _updateFare();
        });
        _startTimer();
      }
    });
  }

  void _startDistanceTracking() {
    // Simulate distance tracking - in real app, this would use GPS
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _distance += 0.1; // Add 100 meters every 5 seconds
          _updateFare();
        });
        _startDistanceTracking();
      }
    });
  }

  void _updateFare() {
    // Calculate fare: $1 base + $0.50 per minute + $1 per km
    final minutes = _rideDuration.inMinutes;
    _currentFare = 1.0 + (minutes * 0.5) + (_distance * 1.0);
  }

  Future<void> _endRide() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.endTrip(_distance, _currentFare);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride ended. Total cost: \$${_currentFare.toStringAsFixed(2)}'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error ending ride: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentTrip = userProvider.user.tripHistory.isNotEmpty
        ? userProvider.user.tripHistory.last
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Active Ride'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scooter Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.electric_scooter,
                      size: 40,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrip?.scooterId ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ride in progress...',
                            style: TextStyle(
                              color: AppColors.textDark.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Ride Stats
            Row(
              children: [
                _buildStatCard(
                  'Duration',
                  _formatDuration(_rideDuration),
                  Icons.timer,
                ),
                SizedBox(width: 12),
                _buildStatCard(
                  'Distance',
                  '${_distance.toStringAsFixed(1)} km',
                  Icons.directions_bike,
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                _buildStatCard(
                  'Current Fare',
                  '\$${_currentFare.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                SizedBox(width: 12),
                _buildStatCard(
                  'Remaining Balance',
                  '\$${(userProvider.user.balance - _currentFare).toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                ),
              ],
            ),

            SizedBox(height: 32),

            // Map Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 50,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Live Ride Tracking',
                      style: TextStyle(
                        color: AppColors.textDark.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Spacer(),

            // End Ride Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _endRide,
                child: Text(
                  'END RIDE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppColors.primary,
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}