import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../utils/constants.dart';
import '../widgets/balance_card.dart';
import '../widgets/scan_button.dart';
import '../widgets/hub_card.dart';
import '../widgets/ride_history_preview.dart';
import '../providers/user_provider.dart';
import 'mock_scanner_screen.dart';
import 'active_ride_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _convertTripsToMap(List<Trip> trips) {
    return trips.map((trip) {
      return {
        'date': '${trip.startTime.day}/${trip.startTime.month}/${trip.startTime.year}',
        'distance': '${trip.distance.toStringAsFixed(1)} km',
        'cost': '\$${trip.cost.toStringAsFixed(2)}',
        'scooterId': trip.scooterId,
      };
    }).toList();
  }

  // Mock data for hubs
  List<Map<String, dynamic>> _getHubs() {
    return [
      {
        'name': 'Main Campus Hub',
        'availableScooters': 5,
        'distance': '0.2 km',
      },
      {
        'name': 'Library Hub',
        'availableScooters': 3,
        'distance': '0.5 km',
      },
      {
        'name': 'Sports Complex Hub',
        'availableScooters': 7,
        'distance': '1.2 km',
      },
    ];
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Since we're using bottom navigation, the profile screen
                  // is already accessible via the bottom nav
                  // We'll just close the menu and let user navigate manually
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();

    Navigator.pushReplacementNamed(context, '/auth');
  }

  Future<void> _scanQRCode(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if profile is completed
    if (!userProvider.isProfileCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete your profile before scanning.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if user has sufficient balance
    if (userProvider.user.balance < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance. Please add funds.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if there's already an active ride
    final hasActiveRide = userProvider.user.tripHistory.isNotEmpty &&
        userProvider.user.tripHistory.last.endTime == null;
    if (hasActiveRide) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You already have an active ride.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate to mock scanner screen and wait for result
    final String? scannedScooterId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MockScannerScreen()),
    );

    // If scan was successful, start the ride
    if (scannedScooterId != null) {
      try {
        await userProvider.startTrip(scannedScooterId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scooter $scannedScooterId unlocked! Have a safe ride.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActiveRideScreen()),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start ride: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildActiveRidePanel(Trip activeTrip) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.electric_scooter,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Active Ride',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                        fontSize: 14,
                        color: AppColors.textDark.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      activeTrip.scooterId,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Started At',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${activeTrip.startTime.hour}:${activeTrip.startTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ActiveRideScreen()),
                  );
                },
                child: Text('View Active Ride'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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

  Widget _buildPromotionsBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9F1C).withOpacity(0.8), Color(0xFFFF9F1C)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Get 20% off your next ride with code: CAMPUS20',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    // Check if there's an active trip (last trip without end time)
    final activeTrip = user.tripHistory.isNotEmpty &&
        user.tripHistory.last.endTime == null
        ? user.tripHistory.last
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Scooter Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              _showProfileMenu(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Card
            BalanceCard(balance: user.balance),

            SizedBox(height: 24),

            // Scan to Unlock Button
            ScanButton(
              onTap: () => _scanQRCode(context),
            ),

            SizedBox(height: 24),

            // Active Ride Panel (conditional)
            if (activeTrip != null) ...[
              _buildActiveRidePanel(activeTrip),
              SizedBox(height: 24),
            ],

            // Scooter Hub Availability
            Text(
              'Nearby Hubs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12),
            ..._getHubs().map((hub) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: HubCard(
                name: hub['name'],
                availableScooters: hub['availableScooters'],
                distance: hub['distance'],
              ),
            )).toList(),

            SizedBox(height: 24),

            // Ride History Preview
            RideHistoryPreview(rides: _convertTripsToMap(user.tripHistory)),

            SizedBox(height: 16),

            // Promotions Banner
            _buildPromotionsBanner(),
          ],
        ),
      ),
    );
  }
}